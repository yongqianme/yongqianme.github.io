# frozen_string_literal: true

require "minitest/autorun"
require_relative "../scripts/sync_substack_posts"

class SyncSubstackPostsTest < Minitest::Test
  def test_request_uses_browser_headers
    request = request_for(
      URI("https://example.substack.com/api/v1/archive"),
      "application/json",
      "X-Respond-With" => "markdown"
    )

    assert_match "Mozilla/5.0", request["User-Agent"]
    assert_equal "https://example.substack.com/", request["Referer"]
    assert_equal "application/json", request["Accept"]
    assert_equal "markdown", request["X-Respond-With"]
  end

  def test_reader_content_removes_response_metadata
    response = <<~TEXT
      Title: A post
      URL Source: https://example.test/p/a-post

      Markdown Content:
      ## Heading

      Post body
    TEXT

    assert_equal "## Heading\n\nPost body", reader_content(response)
  end

  def test_reader_content_rejects_an_unexpected_response
    error = assert_raises(ReaderError) { reader_content("unexpected response") }

    assert_match "Markdown Content", error.message
  end

  def test_archive_falls_back_to_reader_when_api_is_forbidden
    response = Struct.new(:code, :message).new("403", "Forbidden")
    define_singleton_method(:fetch_json) { |_url| raise FetchError.new("https://example.test/archive", response) }
    define_singleton_method(:fetch_reader_json) { |_url| [{ "slug" => "from-reader" }] }

    _stdout, stderr = capture_io do
      assert_equal [{ "slug" => "from-reader" }], archive_posts("https://example.test", 1)
    end
    assert_match "retrying through Jina Reader", stderr
  end

  def test_post_markdown_uses_reader_markdown_body
    post = {
      "id" => 123,
      "title" => "A post",
      "slug" => "a-post",
      "post_date" => "2026-07-24T23:31:04Z",
      "canonical_url" => "https://example.substack.com/p/a-post",
      "body_html" => "",
      "body_markdown" => "## Heading\n\nFull post body"
    }

    output = post_markdown(post)

    assert_includes output, "## Heading\n\nFull post body"
  end
end
