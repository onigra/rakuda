# frozen_string_literal: true

require "optparse"

require_relative "server"

module Rakuda
  class CLI
    def self.run(argv)
      new.run(argv)
    end

    def run(argv)
      command = argv.shift or abort self.class.usage
      options = {source: Dir.pwd, destination: "public", port: 7777} #: CLI::options

      OptionParser.new do |opts|
        opts.banner = "Usage: rkd #{command} [options]"
        opts.on("--source PATH") { |v| options[:source] = v }
        opts.on("--destination PATH") { |v| options[:destination] = v }
        opts.on("--port PORT", Integer) { |v| options[:port] = v }
      end.parse!(argv)

      case command
      when "build"
        Pipeline.new(source: options[:source], destination: options[:destination]).run
      when "serve"
        Server.start(root: options[:destination], port: options[:port])
      else
        abort self.class.usage
      end
    end

    def usage
      self.class.usage
    end

    def self.usage
      "Usage: rkd build|serve [--source PATH] [--destination public] [--port 4000]"
    end
  end
end
