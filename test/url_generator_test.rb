# frozen_string_literal: true

require "test_helper"
require "rakuda/url_generator"

class TestUrlGenerator < Test::Unit::TestCase
  def setup
    @gen = Rakuda::UrlGenerator.new("/blog/:year/:month/:day/:slug/")
  end

  def test_post_url
    date = Time.new(2026, 7, 20, 0, 0, 0, "+09:00")
    url = @gen.post_url(date, "hello-world")
    assert_equal "/blog/2026/07/20/hello-world/", url
  end

  def test_home_pagination_urls
    assert_equal "/", @gen.home_page_url(1)
    assert_equal "/page/2/", @gen.home_page_url(2)
  end
end
