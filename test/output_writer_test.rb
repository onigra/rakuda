# frozen_string_literal: true

require "test_helper"
require "fileutils"
require "tmpdir"
require "rakuda/output_writer"

class TestOutputWriter < Test::Unit::TestCase
  def setup
    @dest = File.join(Dir.mktmpdir, "public")
    @writer = Rakuda::OutputWriter.new(@dest)
  end

  def teardown
    FileUtils.rm_rf(@dest)
  end

  def test_write_page_creates_index_html
    # Given
    @writer.write_page("/blog/2026/01/01/hello/", "<html>hi</html>")
    
    # When
    path = File.join(@dest, "blog/2026/01/01/hello/index.html")

    # Then
    assert File.exist?(path)
    assert_include(File.read(path), "hi")
  end

  def test_write_root_page
    # When
    @writer.write_page("/", "<html>home</html>")
    
    # Then
    assert File.exist?(File.join(@dest, "index.html"))
  end
end
