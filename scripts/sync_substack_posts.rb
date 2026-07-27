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
require "rexml/document"
require "set"
require "time"
require "timeout"
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

REQUEST_ATTEMPTS = 3
RETRYABLE_HTTP_CODES = [403, 408, 425, 429, 500, 502, 503, 504].freeze
BROWSER_USER_AGENT = [
  "Mozilla/5.0 (X11; Linux x86_64)",
  "AppleWebKit/537.36 (KHTML, like Gecko)",
  "Chrome/126.0.0.0 Safari/537.36"
].join(" ").freeze

class FetchError < StandardError
  attr_reader :code

  def initialize(url, response)
    @code = response.code.to_i
    super("Request failed for #{url}: #{response.code} #{response.message}")
  end
end

def parse_options(argv)
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
  end.parse!(argv)

  options
end

def request_for(uri, accept)
  request = Net::HTTP::Get.new(uri)
  request["Accept"] = accept
  request["Accept-Language"] = "en-US,en;q=0.9"
  request["Referer"] = "#{uri.scheme}://#{uri.host}/"
  request["User-Agent"] = BROWSER_USER_AGENT
  request
end

def fetch_body(url, accept:)
  uri = URI(url)
  attempt = 0

  loop do
    attempt += 1
    response = Net::HTTP.start(
      uri.host,
      uri.port,
      use_ssl: uri.scheme == "https",
      open_timeout: 10,
      read_timeout: 30
    ) do |http|
      http.request(request_for(uri, accept))
    end

    return response.body if response.is_a?(Net::HTTPSuccess)

    if RETRYABLE_HTTP_CODES.include?(response.code.to_i) && attempt < REQUEST_ATTEMPTS
      sleep(2**(attempt - 1))
      next
    end

    raise FetchError.new(url, response)
  rescue IOError, SocketError, SystemCallError, Timeout::Error => error
    raise error if attempt >= REQUEST_ATTEMPTS

    sleep(2**(attempt - 1))
  end
end

def fetch_json(url)
  JSON.parse(fetch_body(url, accept: "application/json"))
end

def element_text(item, name)
  item.elements[name]&.text.to_s
end

def parse_feed(xml, limit)
  document = REXML::Document.new(xml)
  items = REXML::XPath.match(document, "//item")

  posts = items.map do |item|
    canonical_url = element_text(item, "link")
    slug = URI(canonical_url).path[%r{/p/([^/?#]+)}, 1]
    next if slug.to_s.empty?

    enclosure = item.elements["enclosure"]
    {
      "id" => element_text(item, "guid").empty? ? canonical_url : element_text(item, "guid"),
      "title" => element_text(item, "title"),
      "slug" => slug,
      "post_date" => Time.parse(element_text(item, "pubDate")).utc.iso8601,
      "canonical_url" => canonical_url,
      "description" => element_text(item, "description"),
      "cover_image" => enclosure&.attributes&.fetch("url", "").to_s,
      "body_html" => element_text(item, "content:encoded"),
      "postTags" => item.get_elements("category").map { |category| { "name" => category.text.to_s } }
    }
  end.compact

  limit ? posts.first(limit) : posts
end

def feed_posts(base_url, limit)
  xml = fetch_body("#{base_url}/feed", accept: "application/rss+xml, application/xml;q=0.9, */*;q=0.8")
  parse_feed(xml, limit)
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
rescue FetchError, JSON::ParserError => error
  warn "Substack archive API unavailable (#{error.message}); falling back to the RSS feed (latest 20 posts)."
  feed_posts(base_url, limit)
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

def run(options)
  FileUtils.mkdir_p(options[:posts_dir]) unless options[:dry_run]
  index = existing_posts(options[:posts_dir])
  archive = archive_posts(options[:base_url], options[:limit])

  created = []
  feed_by_slug = nil
  skipped = []
  updated = []

  archive.each do |archive_post|
    if !options[:overwrite] && imported?(archive_post, index)
      skipped << archive_post["title"]
      next
    end

    post =
      if archive_post["body_html"].to_s.empty?
        begin
          fetch_json("#{options[:base_url]}/api/v1/posts/#{archive_post.fetch("slug")}")
        rescue FetchError, JSON::ParserError => error
          feed_by_slug ||= feed_posts(options[:base_url], nil).each_with_object({}) do |feed_post, index|
            index[feed_post["slug"]] = feed_post
          end
          feed_post = feed_by_slug[archive_post.fetch("slug")]
          raise error unless feed_post

          warn "Substack post API unavailable for #{archive_post.fetch("slug")} (#{error.message}); using RSS content."
          feed_post
        end
      else
        archive_post
      end
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
end

run(parse_options(ARGV)) if $PROGRAM_NAME == __FILE__
