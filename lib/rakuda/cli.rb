# frozen_string_literal: true

require "optparse"

require_relative "server"

module Rakuda
  class CLI
    def self.run(argv)
      command =
        case argv.first
        when "build", "serve" then argv.shift
        when nil then :default
        # サブコマンドを省略して、最初の引数がオプション（-- で始まる）のときは :default を実行
        when /\A-/ then :default
        else abort usage
        end

      options = {source: Dir.pwd, destination: "public", port: 7777} #: CLI::options

      OptionParser.new do |opts|
        opts.banner = "Usage: rkd [build|serve] [options]"
        opts.on("--source PATH") { |v| options[:source] = v }
        opts.on("--destination PATH") { |v| options[:destination] = v }
        opts.on("--port PORT", Integer) { |v| options[:port] = v }
      end.parse!(argv)

      case command
      when "build"
        build(options)
      when "serve"
        serve(options)
      when :default
        build(options)
        serve(options)
      else
        abort usage
      end
    end

    def self.usage
      "Usage: rkd [build|serve] [--source PATH] [--destination public] [--port 7777]"
    end

    class << self
      private

      def build(options)
        Pipeline.new(source: options[:source], destination: options[:destination]).run
      end

      def serve(options)
        Server.start(root: options[:destination], port: options[:port])
      end
    end
  end
end
