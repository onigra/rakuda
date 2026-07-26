# frozen_string_literal: true

require_relative "../site_context"
require_relative "../url_generator"
require_relative "../paginator"

module Rakuda
  module Generators
    class Home
      def initialize(config:, posts:, renderer:, markdown:)
        @config = config
        @posts = posts
        @renderer = renderer
        @markdown = markdown
        @site = SiteContext.build(config)
        @url_gen = UrlGenerator.new(config.permalink_post || "/:year/:month/:day/:slug/")
      end

      def generate
        paginated = Paginator.paginate(@posts, per_page: @config.paginate)
        paginated = [Paginator::PaginatedPage.new(items: [], number: 1, total: 1)] if paginated.empty?

        paginated.map do |page|
          page_posts = page.items.map { |post| post_to_list_hash(post) }
          paginator = build_paginator(paginated, page)

          html = @renderer.render("list", {
            site: @site,
            page: {
              title: @config.title,
              url: @url_gen.home_page_url(page.number),
              is_home: true
            },
            pages: page_posts,
            paginator: paginator
          })

          {url: @url_gen.home_page_url(page.number), content: html}
        end
      end

      private

      def build_paginator(paginated, current_page)
        total = paginated.size
        current = current_page.number

        {
          pages: paginated.map { |page| @url_gen.home_page_url(page.number) },
          current: current,
          total: total,
          prev: (current > 1) ? @url_gen.home_page_url(current - 1) : nil,
          next: (current < total) ? @url_gen.home_page_url(current + 1) : nil
        }
      end

      def post_to_list_hash(post)
        {
          title: post.title,
          date: post.date,
          url: post.url,
          categories: post.categories,
          summary: @markdown.render(post.summary)
        }
      end
    end
  end
end
