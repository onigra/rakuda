# frozen_string_literal: true

require "test_helper"
require "rakuda/generators/rss"

class TestRssGenerator < Test::Unit::TestCase
  def setup
    @root = File.expand_path("../fixtures/minimal", __dir__)
    @config = Rakuda::Config.load(File.join(@root, "site.yml"))
    @renderer = Rakuda::TemplateRenderer.new(File.join(@root, "layouts"))
  end

  def test_renders_feed_items
    # Given
    posts = [
      Factories::PostFactory.build_post(
        title: "Hello",
        slug: "hello",
        date: Date.new(2026, 1, 1),
        url: "/blog/2026/01/01/hello/"
      )
    ]

    # When
    xml = Rakuda::Generators::Rss.new(
      config: @config,
      posts: posts,
      renderer: @renderer
    ).generate

    # Then
    assert_include(xml, "<title>Test Site</title>")
    assert_include(xml, "<title>Hello</title>")
    assert_include(xml, "https://example.com/blog/2026/01/01/hello/")
  end
end
