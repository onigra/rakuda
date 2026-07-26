# frozen_string_literal: true

require "test_helper"
require "fileutils"
require "rakuda/pipeline"

class TestPipeline < Test::Unit::TestCase
  def test_builds_fixture_site
    # Given
    source = File.expand_path("fixtures/minimal", __dir__)
    dest = File.join(Dir.mktmpdir, "out")

    # When
    Rakuda::Pipeline.new(source: source, destination: dest).run

    # Then
    assert File.exist?(File.join(dest, "index.html"))
    assert File.exist?(File.join(dest, "blog/2026/01/01/hello/index.html"))
    assert File.exist?(File.join(dest, "index.xml"))
    assert File.exist?(File.join(dest, "robots.txt"))
  ensure
    FileUtils.rm_rf(dest) if dest
  end
end
