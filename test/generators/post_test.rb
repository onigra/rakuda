# frozen_string_literal: true

require "test_helper"
require "rakuda/generators/post"

class TestPostGenerator < Test::Unit::TestCase
  def setup
    @root = File.expand_path("../fixtures/minimal", __dir__)
    @config = Rakuda::Config.load(File.join(@root, "site.yml"))
    @renderer = Rakuda::TemplateRenderer.new(File.join(@root, "layouts"))
    @markdown = Rakuda::MarkdownRenderer
  end

  def test_renders_single_post
    # Given
    post = Factories::PostFactory.build_post(
      title: "Hello",
      slug: "hello",
      body: "Intro paragraph.\n\nRest of post.",
      url: "/blog/2026/01/01/hello/",
      summary: "Intro paragraph."
    )

    # When
    pages = Rakuda::Generators::Post.new(
      config: @config,
      posts: [post],
      renderer: @renderer,
      markdown: @markdown
    ).generate

    # Then
    # 1ページに分割されている
    assert_equal 1, pages.size

    # 各ページのURLが正しい
    assert_equal "/blog/2026/01/01/hello/", pages.first[:url]

    # 各ページの内容が正しい
    assert_include(pages.first[:content], "<h1>Hello</h1>")
    assert_include(pages.first[:content], "Intro paragraph.")
  end
end
