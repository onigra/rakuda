# frozen_string_literal: true

require "test_helper"
require "rakuda/content_loader"
require "rakuda/config"

class TestContentLoader < Test::Unit::TestCase
  def setup
    @root = File.expand_path("fixtures/minimal", __dir__)
    @config = Rakuda::Config.load(File.join(@root, "site.yml"))
  end
  
  def test_loads_posts
    # When
    result = Rakuda::ContentLoader.load(@root, @config)
    
    # Then
    assert_equal 1, result.posts.size
  end

  def test_builds_post_url_and_summary
    # Given
    result = Rakuda::ContentLoader.load(@root, @config)
    
    # When
    post = result.posts.first
    
    # Then
    assert_equal "Hello", post.title
    assert_equal "/blog/2026/01/01/hello/", post.url
    assert_include(post.summary, "Intro paragraph")
    assert_not_include(post.summary, "Rest of post")
  end

  def test_loads_pages
    # When
    result = Rakuda::ContentLoader.load(@root, @config)
    
    # Then
    assert_equal 1, result.pages.size
    assert_equal "/about/", result.pages.first.url
  end
end
