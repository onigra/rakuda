# frozen_string_literal: true

require_relative "../site_context"

module Rakuda
  module Generators
    ###
    #
    # Pipeline が参照する固定ページ（/about/ 等） を出力するための generator
    #
    class Page
      #: @rbs config: Config
      #: @rbs page: Page
      #: @rbs renderer: TemplateRenderer
      #: @rbs markdown: MarkdownRenderer
      #: @rbs return: Hash[Symbol, String]
      def initialize(config:, page:, renderer:, markdown:)
        @config = config
        @page = page
        @renderer = renderer
        @markdown = markdown
        @site = SiteContext.build(config)
      end

      #: @rbs return: Hash[Symbol, String]
      def generate
        content_html = @markdown.render(@page.body)
        html = @renderer.render("single", {
          site: @site,
          page: page_to_hash(content_html)
        })
        {url: @page.url, content: html}
      end

      private

      #: @rbs content_html: String
      #: @rbs return: Hash[Symbol, untyped]
      def page_to_hash(content_html)
        {
          title: @page.title,
          date: @page.date,
          url: @page.url,
          categories: @page.categories,
          content: content_html,
          summary: @page.summary,
          has_more: @page.has_more,
          is_home: false
        }
      end
    end
  end
end
