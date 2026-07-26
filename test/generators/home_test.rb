# frozen_string_literal: true

require "test_helper"
require "rakuda/generators/home"

class TestHomeGenerator < Test::Unit::TestCase
  def setup
    @root = File.expand_path("../fixtures/minimal", __dir__)
    @config = Rakuda::Config.load(File.join(@root, "site.yml"))
    @renderer = Rakuda::TemplateRenderer.new(File.join(@root, "layouts"))
    @markdown = Rakuda::MarkdownRenderer
  end

  def test_paginates_25_posts_into_3_pages
    # Given
    posts = (1..25).map do |n|
      Factories::PostFactory.build_post(
        title: "Post #{n}",
        slug: "post-#{n}",
        date: Date.new(2026, 1, n),
        url: "/blog/2026/01/#{format("%02d", n)}/post-#{n}/",
        summary: "Summary #{n}"
      )
    end

    # When
    pages = Rakuda::Generators::Home.new(
      config: @config,
      posts: posts,
      renderer: @renderer,
      markdown: @markdown
    ).generate

    # Then
    # 3ページに分割されている
    assert_equal 3, pages.size

    # 各ページのURLが正しい
    assert_equal ["/", "/page/2/", "/page/3/"], pages.map { |page| page[:url] }

    # 各ページに title の内容が含まれている
    assert_include(pages.first[:content], "Post 1")
    assert_include(pages.last[:content], "Post 25")

    # 各ページのナビゲーションが正しい
    assert_include(pages.first[:content], 'class="next"')
    assert_include(pages.last[:content], 'class="prev"')
  end
end
