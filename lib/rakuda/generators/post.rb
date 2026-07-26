# frozen_string_literal: true

require_relative "../site_context"

module Rakuda
  module Generators
    class Post
      def initialize(config:, posts:, renderer:, markdown:)
        @config = config
        @posts = posts
        @renderer = renderer
        @markdown = markdown
        @site = SiteContext.build(config)
      end

      def generate
        @posts.map do |post|
          content_html = @markdown.render(post.body)
          html = @renderer.render("single", {
            site: @site,
            page: post_to_page_hash(post, content_html)
          })
          {url: post.url, content: html}
        end
      end

      private

      def post_to_page_hash(post, content_html)
        {
          title: post.title,
          date: post.date,
          url: post.url,
          categories: post.categories,
          content: content_html,
          summary: @markdown.render(post.summary),
          is_home: false
        }
      end
    end
  end
end
