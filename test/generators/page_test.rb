# frozen_string_literal: true

require "test_helper"
require "rakuda/generators/page"
require "rakuda/page_loader"

class TestPageGenerator < Test::Unit::TestCase
  def setup
    @root = File.expand_path("../fixtures/minimal", __dir__)
    @config = Rakuda::Config.load(File.join(@root, "site.yml"))
    @renderer = Rakuda::TemplateRenderer.new(File.join(@root, "layouts"))
    @markdown = Rakuda::MarkdownRenderer
  end

  def test_renders_static_page
    # Given
    page = Rakuda::PageLoader.load(@root, @config).first

    # When
    result = Rakuda::Generators::Page.new(
      config: @config,
      page: page,
      renderer: @renderer,
      markdown: @markdown
    ).generate

    # Then
    assert_equal "/about/", result[:url]
    assert_include(result[:content], "<h1>About</h1>")
    assert_include(result[:content], "About body.")
  end
end
