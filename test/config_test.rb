# frozen_string_literal: true

require "test_helper"
require "rakuda/config"

class TestConfig < Test::Unit::TestCase
  def setup
    @path = File.expand_path("fixtures/minimal/site.yml", __dir__)
  end

  data(
    "base_url" => ["https://example.com", :base_url],
    "paginate" => [10, :paginate],
    "summary_length" => [100, :summary_length],
    "permalink_post" => ["/blog/:year/:month/:day/:slug/", :permalink_post]
  )
  def test_loads_site_yml(data)
    expected, attribute = data
    config = Rakuda::Config.load(@path)
    assert_equal expected, config.public_send(attribute)
  end
end
