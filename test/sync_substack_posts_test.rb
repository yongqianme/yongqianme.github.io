# frozen_string_literal: true

require "minitest/autorun"
require_relative "../scripts/sync_substack_posts"

class SyncSubstackPostsTest < Minitest::Test
  FEED = <<~XML
    <?xml version="1.0" encoding="UTF-8"?>
    <rss xmlns:content="http://purl.org/rss/1.0/modules/content/" version="2.0">
      <channel>
        <item>
          <title>A post title</title>
          <description>A post description</description>
          <link>https://example.substack.com/p/a-post</link>
          <guid>post-123</guid>
          <pubDate>Fri, 24 Jul 2026 23:31:04 GMT</pubDate>
          <enclosure url="https://example.com/cover.jpg" length="0" type="image/jpeg"/>
          <category>Robotics</category>
          <content:encoded><![CDATA[<p>Full post body</p>]]></content:encoded>
        </item>
      </channel>
    </rss>
  XML

  def test_request_uses_browser_headers
    request = request_for(URI("https://example.substack.com/api/v1/archive"), "application/json")

    assert_match "Mozilla/5.0", request["User-Agent"]
    assert_equal "https://example.substack.com/", request["Referer"]
    assert_equal "application/json", request["Accept"]
  end

  def test_parse_feed_returns_post_data_needed_by_importer
    post = parse_feed(FEED, nil).first

    assert_equal "post-123", post["id"]
    assert_equal "a-post", post["slug"]
    assert_equal "2026-07-24T23:31:04Z", post["post_date"]
    assert_equal "<p>Full post body</p>", post["body_html"]
    assert_equal "https://example.com/cover.jpg", post["cover_image"]
    assert_equal [{ "name" => "Robotics" }], post["postTags"]
  end

  def test_parse_feed_honors_limit
    assert_empty parse_feed(FEED, 0)
  end

  def test_archive_falls_back_to_feed_when_api_is_forbidden
    response = Struct.new(:code, :message).new("403", "Forbidden")
    define_singleton_method(:fetch_json) { |_url| raise FetchError.new("https://example.test/archive", response) }
    define_singleton_method(:feed_posts) { |_base_url, _limit| [{ "slug" => "from-feed" }] }

    _stdout, stderr = capture_io do
      assert_equal [{ "slug" => "from-feed" }], archive_posts("https://example.test", 1)
    end
    assert_match "falling back to the RSS feed", stderr
  end
end
