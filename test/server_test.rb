# frozen_string_literal: true

require "test_helper"
require "fileutils"
require "net/http"
require "rack/mock"
require "rakuda/server"
require "rakuda/pipeline"

class TestServer < Test::Unit::TestCase
  def setup
    @source = File.expand_path("fixtures/minimal", __dir__)
    @dest = File.join(Dir.mktmpdir, "out")
    Rakuda::Pipeline.new(source: @source, destination: @dest).run
  end

  def teardown
    FileUtils.rm_rf(@dest)
  end

  def test_serves_index_html
    # Given
    app = Rakuda::Server.app(@dest)

    # When
    status, _headers, body = app.call(Rack::MockRequest.env_for("/"))
    content = read_body(body)

    # Then
    assert_equal 200, status
    assert_include(content, "Test Site")
  end

  def test_serves_directory_index
    # Given
    app = Rakuda::Server.app(@dest)

    # When
    status, _headers, body = app.call(Rack::MockRequest.env_for("/about/"))
    content = read_body(body)

    # Then
    assert_equal 200, status
    assert_include(content, "About")
  end

  def test_start_serves_root_over_http
    # Given
    port = free_port
    server_thread = Thread.new { Rakuda::Server.start(root: @dest, port: port) }
    wait_for_server(port)

    # When
    response = Net::HTTP.get_response(URI("http://127.0.0.1:#{port}/"))

    # Then
    assert_equal "200", response.code
    assert_include(response.body, "Test Site")
  ensure
    server_thread&.kill
  end

  private

  def read_body(body)
    buffer = +""
    body.each { |chunk| buffer << chunk }
    buffer
  end

  def free_port
    server = TCPServer.new("127.0.0.1", 0)
    server.addr[1]
  ensure
    server&.close
  end

  def wait_for_server(port, timeout: 5)
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout
    loop do
      Net::HTTP.get_response(URI("http://127.0.0.1:#{port}/"))
      break
    rescue Errno::ECONNREFUSED
      raise "server did not start on port #{port}" if Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline

      sleep 0.05
    end
  end
end
