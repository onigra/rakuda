# frozen_string_literal: true

require "test_helper"
require "rakuda/generators/taxonomy"

class TestTaxonomyGenerator < Test::Unit::TestCase
  def setup
    @root = File.expand_path("../fixtures/minimal", __dir__)
    @config = Rakuda::Config.load(File.join(@root, "site.yml"))
    @renderer = Rakuda::TemplateRenderer.new(File.join(@root, "layouts"))
    @markdown = Rakuda::MarkdownRenderer
  end

  def test_creates_page_per_category
    # Given
    posts = [
      Factories::PostFactory.build_post(title: "Ruby post", slug: "ruby-post", categories: ["ruby"], url: "/blog/2026/01/01/ruby-post/"),
      Factories::PostFactory.build_post(title: "Go post", slug: "go-post", categories: ["go"], url: "/blog/2026/01/02/go-post/")
    ]

    # When
    pages = Rakuda::Generators::Taxonomy.new(
      config: @config,
      posts: posts,
      renderer: @renderer,
      markdown: @markdown
    ).generate

    # Then
    # 2ページに分割されている
    assert_equal 2, pages.size

    # 各ページのURLが正しい
    urls = pages.map { |page| page[:url] }.sort
    assert_equal ["/categories/go/", "/categories/ruby/"], urls

    # 各ページの内容が正しい
    assert_include(pages.find { |page| page[:url] == "/categories/ruby/" }[:content], "Ruby post")
    assert_include(pages.find { |page| page[:url] == "/categories/go/" }[:content], "Go post")
  end
end
