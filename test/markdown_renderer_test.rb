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
end
