# frozen_string_literal: true

require "cgi/escape"

require_relative "../site_context"
require_relative "../url_generator"

module Rakuda
  module Generators
    class Taxonomy
      def initialize(config:, posts:, renderer:, markdown:)
        @config = config
        @posts = posts
        @renderer = renderer
        @markdown = markdown
        @site = SiteContext.build(config)
        @url_gen = UrlGenerator.new(config.permalink_post || "/:year/:month/:day/:slug/")
      end

      def generate
        @posts.flat_map(&:categories).uniq.map do |category|
          category_posts = @posts.select { |post| post.categories.include?(category) }
          page_posts = category_posts.map { |post| post_to_list_hash(post) }
          url = @url_gen.category_url(category)

          html = @renderer.render("list", {
            site: @site,
            page: {
              title: category,
              url: url,
              is_home: false
            },
            pages: page_posts,
            paginator: {
              pages: [url],
              current: 1,
              total: 1,
              prev: nil,
              next: nil
            }
          })

          {url: url, content: html}
        end
      end

      private

      def post_to_list_hash(post)
        {
          title: post.title,
          date: post.date,
          url: post.url,
          categories: post.categories,
          summary: CGI.escapeHTML(post.summary),
          has_more: post.has_more
        }
      end
    end
  end
end
