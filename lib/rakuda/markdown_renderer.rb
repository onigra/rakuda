# frozen_string_literal: true

require "kramdown"
require "kramdown-parser-gfm"
require "rinku"

module Rakuda
  module MarkdownRenderer
    SKIP_TAGS = %w[a pre code].freeze

    @html_cache = {} #: Hash[String, String]

    def self.render(markdown, autolink: true)
      html = html_for(markdown)
      return html unless autolink && markdown.include?("http")

      Rinku.auto_link(html, :all, nil, SKIP_TAGS)
    end

    def self.html_for(markdown)
      @html_cache[markdown] ||= Kramdown::Document.new(markdown, input: "GFM").to_html
    end
    private_class_method :html_for
  end
end
