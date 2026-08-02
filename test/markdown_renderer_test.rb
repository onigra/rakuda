# frozen_string_literal: true

require "test_helper"
require "rakuda/markdown_renderer"

class TestMarkdownRenderer < Test::Unit::TestCase
  def test_renders_fenced_code_block
    html = Rakuda::MarkdownRenderer.render("```ruby\nputs 1\n```")
    assert_include(html, "<code")
    assert_include(html, "puts 1")
  end

  def test_renders_heading
    html = Rakuda::MarkdownRenderer.render("## Hello")
    assert_include(html, "<h2")
    assert_include(html, "Hello")
  end

  def test_autolinks_bare_https_url
    html = Rakuda::MarkdownRenderer.render("Visit https://example.com for more")
    assert_include(html, '<a href="https://example.com">https://example.com</a>')
  end

  def test_autolinks_bare_http_url
    html = Rakuda::MarkdownRenderer.render("Visit http://example.com for more")
    assert_include(html, '<a href="http://example.com">http://example.com</a>')
  end

  def test_strips_trailing_punctuation_from_url
    html = Rakuda::MarkdownRenderer.render("See https://example.com.")
    assert_include(html, '<a href="https://example.com">https://example.com</a>.')
  end

  def test_does_not_autolink_url_in_fenced_code_block
    html = Rakuda::MarkdownRenderer.render("```\nhttps://example.com\n```")
    assert_not_include(html, "<a ")
  end

  def test_does_not_autolink_url_in_inline_code
    html = Rakuda::MarkdownRenderer.render("Use `https://example.com` here.")
    assert_not_include(html, "<a ")
  end

  def test_does_not_double_link_existing_anchor
    html = Rakuda::MarkdownRenderer.render("<https://example.com>")
    assert_equal 1, html.scan("<a ").length
  end

  def test_skips_autolink_when_disabled
    html = Rakuda::MarkdownRenderer.render("Visit https://example.com", autolink: false)
    assert_not_include(html, "<a ")
  end
end
