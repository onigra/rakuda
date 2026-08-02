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
        @posts.each_with_index.map do |post, index|
          content_html = @markdown.render(post.body)
          html = @renderer.render("single", {
            site: @site,
            page: post_to_page_hash(post, content_html),
            prev_post: adjacent_post(index, 1),
            next_post: adjacent_post(index, -1)
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
          summary: post.summary,
          has_more: post.has_more,
          is_home: false
        }
      end

      def adjacent_post(index, offset)
        target_index = index + offset
        return nil if target_index.negative? || target_index >= @posts.size

        post = @posts[target_index]
        {title: post.title, url: post.url}
      end
    end
  end
end
