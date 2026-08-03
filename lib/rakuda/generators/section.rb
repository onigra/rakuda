# frozen_string_literal: true

require "cgi/escape"

require_relative "../site_context"

module Rakuda
  module Generators
    class Section
      def initialize(config:, posts:, renderer:, markdown:)
        @config = config
        @posts = posts
        @renderer = renderer
        @markdown = markdown
        @site = SiteContext.build(config)
      end

      def generate
        grouped_entries = @posts.group_by { |post| post.date.year.to_s }
          .transform_values { |posts| posts.map { |post| post_to_list_hash(post) } }

        html = @renderer.render("section", {
          site: @site,
          page: {
            title: "Posts",
            url: "/post/",
            is_home: false
          },
          pages: @posts.map { |post| post_to_list_hash(post) },
          grouped_by_year: grouped_entries
        })

        [{url: "/post/", content: html}]
      end

      private

      def post_to_list_hash(post)
        {
          title: post.title,
          date: post.date,
          url: post.url,
          summary: CGI.escapeHTML(post.summary),
          has_more: post.has_more
        }
      end
    end
  end
end
