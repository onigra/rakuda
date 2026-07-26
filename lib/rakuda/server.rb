# frozen_string_literal: true

require "rack"
require "rack/static"
require "rackup/server"

module Rakuda
  module Server
    def self.app(root)
      Rack::Static.new(
        ->(_env) { [404, {}, []] },
        root: root,
        urls: [""],
        index: "index.html"
      )
    end

    def self.start(root:, port: 7777)
      Rackup::Server.start(app: app(root), Port: port, Host: "127.0.0.1")
    end
  end
end
