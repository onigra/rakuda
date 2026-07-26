# frozen_string_literal: true

require "kramdown"
require "kramdown-parser-gfm"

module Rakuda
  module MarkdownRenderer
    def self.render(markdown)
      Kramdown::Document.new(markdown, input: "GFM").to_html
    end
  end
end
