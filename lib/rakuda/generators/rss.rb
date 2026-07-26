# frozen_string_literal: true

require_relative "../site_context"

module Rakuda
  module Generators
    class Rss
      def initialize(config:, posts:, renderer:)
        @config = config
        @posts = posts
        @renderer = renderer
        @site = SiteContext.build(config)
      end

      def generate
        post_hashes = @posts.map do |post|
          {
            title: post.title,
            url: post.url,
            date: post.date
          }
        end

        @renderer.render("rss", {
          site: @site,
          posts: post_hashes
        })
      end
    end
  end
end
