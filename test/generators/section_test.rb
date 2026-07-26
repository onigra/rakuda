# frozen_string_literal: true

require "test_helper"
require "rakuda/generators/section"

class TestSectionGenerator < Test::Unit::TestCase
  def setup
    @root = File.expand_path("../fixtures/minimal", __dir__)
    @config = Rakuda::Config.load(File.join(@root, "site.yml"))
    @renderer = Rakuda::TemplateRenderer.new(File.join(@root, "layouts"))
    @markdown = Rakuda::MarkdownRenderer
  end

  def test_groups_posts_by_year
    # Given
    posts = [
      Factories::PostFactory.build_post(title: "Old", slug: "old", date: Date.new(2025, 12, 31), url: "/blog/2025/12/31/old/"),
      Factories::PostFactory.build_post(title: "New", slug: "new", date: Date.new(2026, 1, 1), url: "/blog/2026/01/01/new/")
    ]

    # when
    pages = Rakuda::Generators::Section.new(
      config: @config,
      posts: posts,
      renderer: @renderer,
      markdown: @markdown
    ).generate

    # Then
    # 1ページに分割されている
    assert_equal 1, pages.size

    # 各ページのURLが正しい
    assert_equal "/post/", pages.first[:url]

    # 各ページの内容が正しい
    assert_include(pages.first[:content], 'class="year">2025</h2>')
    assert_include(pages.first[:content], 'class="year">2026</h2>')
  end
end
