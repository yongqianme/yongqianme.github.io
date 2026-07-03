#!/usr/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

require "cgi"
require "date"
require "fileutils"
require "json"
require "net/http"
require "optparse"
require "set"
require "time"
require "uri"
require "yaml"

begin
  require "nokogiri"
rescue LoadError
  Nokogiri = nil
end

def configured_limit
  raw_value = ENV["SUBSTACK_SYNC_LIMIT"].to_s.strip
  return nil if raw_value.empty?

  limit = raw_value.to_i
  limit.positive? ? limit : nil
end

OPTIONS = {
  base_url: ENV.fetch("SUBSTACK_BASE_URL", "https://yongqianme.substack.com"),
  limit: configured_limit,
  posts_dir: "_posts",
  dry_run: false,
  overwrite: false
}.freeze

options = OPTIONS.dup

OptionParser.new do |parser|
  parser.banner = "Usage: ruby scripts/sync_substack_posts.rb [options]"

  parser.on("--base-url URL", "Substack publication URL") do |value|
    options[:base_url] = value.sub(%r{/\z}, "")
  end

  parser.on("--limit N", Integer, "Maximum archive posts to inspect; use 0 for the full archive") do |value|
    options[:limit] = value.positive? ? value : nil
  end

  parser.on("--all", "Inspect the full Substack archive") do
    options[:limit] = nil
  end

  parser.on("--posts-dir DIR", "Jekyll posts directory") do |value|
    options[:posts_dir] = value
  end

  parser.on("--dry-run", "Show what would be imported without writing files") do
    options[:dry_run] = true
  end

  parser.on("--overwrite", "Overwrite previously imported Substack posts") do
    options[:overwrite] = true
  end
end.parse!

def fetch_json(url)
  uri = URI(url)
  request = Net::HTTP::Get.new(uri)
  request["Accept"] = "application/json"
  request["User-Agent"] = "qianyong.me-substack-sync/1.0"

  response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
    http.request(request)
  end

  unless response.is_a?(Net::HTTPSuccess)
    raise "Request failed for #{url}: #{response.code} #{response.message}"
  end

  JSON.parse(response.body)
end

def archive_posts(base_url, limit)
  posts = []
  offset = 0
  page_size = 50

  loop do
    break if limit && posts.length >= limit

    remaining = limit ? limit - posts.length : page_size
    batch_size = [remaining, page_size].min
    url = "#{base_url}/api/v1/archive?sort=new&search=&offset=#{offset}&limit=#{batch_size}"
    page = fetch_json(url)
    break if page.empty?

    posts.concat(page)
    offset += page.length
  end

  limit ? posts.first(limit) : posts
end

def normalize_title(value)
  value.to_s
       .downcase
       .gsub(/[’‘`]/, "'")
       .gsub(/[“”]/, '"')
       .gsub(/[^\p{Alnum}]+/, " ")
       .strip
end

def front_matter_for(path)
  content = File.read(path, encoding: "UTF-8")
  match = content.match(/\A---\s*\n(.*?)\n---\s*\n/m)
  return {} unless match

  YAML.safe_load(
    match[1],
    permitted_classes: [Date, Time],
    aliases: true
  ) || {}
rescue Psych::Exception
  {}
end

def existing_posts(posts_dir)
  index = {
    ids: Set.new,
    slugs: Set.new,
    titles: Set.new
  }

  Dir.glob(File.join(posts_dir, "*.md")).each do |path|
    metadata = front_matter_for(path)
    index[:ids] << metadata["substack_id"].to_s if metadata["substack_id"]
    index[:slugs] << metadata["substack_slug"].to_s if metadata["substack_slug"]

    if metadata["substack_url"].to_s.match(%r{/p/([^/?#]+)})
      index[:slugs] << Regexp.last_match(1)
    end

    if metadata["permalink"].to_s.match(%r{/([^/]+)/?\z})
      index[:slugs] << Regexp.last_match(1).downcase
    end

    filename_slug = File.basename(path, ".md").sub(/\A\d{4}-\d{2}-\d{2}-/, "")
    index[:slugs] << filename_slug.downcase
    index[:titles] << normalize_title(metadata["title"])
  end

  index
end

def imported?(post, index)
  slug = post["slug"].to_s.downcase
  title = normalize_title(post["title"])

  index[:ids].include?(post["id"].to_s) ||
    index[:slugs].include?(slug) ||
    index[:titles].include?(title)
end

def clean_body_html(html)
  return "" if html.to_s.strip.empty?
  return fallback_clean_body(html) unless Nokogiri

  fragment = Nokogiri::HTML::DocumentFragment.parse(html)
  fragment.css("picture").each do |node|
    image = node.at_css("img")
    node.replace(image || node.children)
  end

  fragment.css("script, style, button, svg, source, .image-link-expand").remove

  fragment.css("span").each do |node|
    node.replace(node.children)
  end

  fragment.css("*").each do |node|
    allowed = %w[href src alt title width height]
    node.attribute_nodes.each do |attribute|
      node.remove_attribute(attribute.name) unless allowed.include?(attribute.name)
    end
  end

  fragment.css("p, div, figure, a").each do |node|
    node.remove if node.text.strip.empty? && node.css("img, iframe, video").empty?
  end

  body = fragment.to_html
  body.gsub!(%r{</(p|h[1-6]|ul|ol|li|blockquote|figure|div)>}, "\\0\n")
  body.gsub!(/\n{3,}/, "\n\n")
  body.strip
end

def fallback_clean_body(html)
  html.to_s
      .gsub(%r{<script\b[^>]*>.*?</script>}mi, "")
      .gsub(%r{<style\b[^>]*>.*?</style>}mi, "")
      .gsub(%r{<button\b[^>]*>.*?</button>}mi, "")
      .gsub(%r{<svg\b[^>]*>.*?</svg>}mi, "")
      .gsub(/\sdata-[a-z-]+=(["']).*?\1/mi, "")
      .gsub(/\sclass=(["']).*?\1/mi, "")
      .gsub(/\sstyle=(["']).*?\1/mi, "")
      .strip
end

def yaml_front_matter(metadata)
  YAML.dump(metadata).sub(/\A---\n/, "---\n")
end

def post_filename(posts_dir, date, slug)
  safe_slug = slug.downcase.gsub(/[^a-z0-9-]+/, "-").gsub(/-{2,}/, "-").gsub(/\A-|-+\z/, "")
  File.join(posts_dir, "#{date.strftime("%Y-%m-%d")}-#{safe_slug}.md")
end

def post_markdown(post)
  date = Time.parse(post.fetch("post_date")).utc.to_date
  slug = post.fetch("slug")
  tags = Array(post["postTags"]).map { |tag| tag["name"].to_s.strip }.reject(&:empty?).uniq
  canonical_url = post["canonical_url"].to_s

  metadata = {
    "title" => post.fetch("title"),
    "date" => date.strftime("%Y-%m-%d"),
    "permalink" => "/posts/#{date.year}/#{date.strftime("%m")}/#{slug}/",
    "categories" => ["Writing"],
    "tags" => tags,
    "substack_id" => post.fetch("id"),
    "substack_slug" => slug,
    "substack_url" => canonical_url
  }

  metadata["excerpt"] = post["description"].to_s unless post["description"].to_s.empty?
  metadata["image"] = post["cover_image"].to_s unless post["cover_image"].to_s.empty?

  body_html = clean_body_html(post["body_html"])
  body_html = CGI.escapeHTML(post["truncated_body_text"].to_s) if body_html.empty?

  body = +""
  body << "> Originally published on [Substack](#{canonical_url}).\n\n" unless canonical_url.empty?
  body << body_html
  body << "\n"

  "#{yaml_front_matter(metadata)}---\n\n#{body}"
end

FileUtils.mkdir_p(options[:posts_dir]) unless options[:dry_run]
index = existing_posts(options[:posts_dir])
archive = archive_posts(options[:base_url], options[:limit])

created = []
skipped = []
updated = []

archive.each do |archive_post|
  if !options[:overwrite] && imported?(archive_post, index)
    skipped << archive_post["title"]
    next
  end

  post = fetch_json("#{options[:base_url]}/api/v1/posts/#{archive_post.fetch("slug")}")
  date = Time.parse(post.fetch("post_date")).utc.to_date
  path = post_filename(options[:posts_dir], date, post.fetch("slug"))
  existed = File.exist?(path)

  if existed && !options[:overwrite]
    skipped << post["title"]
    next
  end

  if options[:dry_run]
    puts "[dry-run] #{existed ? "update" : "create"} #{path}"
  else
    File.write(path, post_markdown(post), encoding: "UTF-8")
  end

  existed ? updated << path : created << path
end

puts "Substack sync complete"
puts "  inspected: #{archive.length}"
puts "  created:   #{created.length}"
puts "  updated:   #{updated.length}"
puts "  skipped:   #{skipped.length}"
