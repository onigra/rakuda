# frozen_string_literal: true

require "test_helper"
require "rakuda/generators/robots"

class TestRobotsGenerator < Test::Unit::TestCase
  def setup
    @root = File.expand_path("../fixtures/minimal", __dir__)
    @config = Rakuda::Config.load(File.join(@root, "site.yml"))
  end

  def test_matches_hugo_output
    # When
    content = Rakuda::Generators::Robots.new(config: @config).generate

    # Then
    assert_equal("User-agent: *", content)
  end
end
