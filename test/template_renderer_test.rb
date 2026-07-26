# frozen_string_literal: true

require "test_helper"
require "rakuda/template_renderer"
require "rakuda/site_context"
require "rakuda/config"

class TestTemplateRenderer < Test::Unit::TestCase
  def test_renders_erb_layout
    # Given
    root = File.expand_path("fixtures/minimal", __dir__)
    config = Rakuda::Config.load(File.join(root, "site.yml"))
    renderer = Rakuda::TemplateRenderer.new(File.join(root, "layouts"))

    # When
    html = renderer.render("single", {
      site: Rakuda::SiteContext.build(config),
      page: {title: "Hi", content: "<p>Body</p>"}
    })

    # Then
    assert_include(html, "<h1>Hi</h1>")
    assert_include(html, "<p>Body</p>")
  end
end
