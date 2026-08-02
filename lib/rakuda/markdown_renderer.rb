# frozen_string_literal: true

require "kramdown"
require "kramdown-parser-gfm"
require "rinku"

module Rakuda
  module MarkdownRenderer
    SKIP_TAGS = %w[a pre code].freeze

    def self.render(markdown, autolink: true)
      html = Kramdown::Document.new(markdown, input: "GFM").to_html
      return html unless autolink && markdown.include?("http")

      Rinku.auto_link(html, :all, nil, SKIP_TAGS)
    end
  end
end
