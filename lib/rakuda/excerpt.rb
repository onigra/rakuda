# frozen_string_literal: true

require_relative "markdown_renderer"

module Rakuda
  module Excerpt
    DEFAULT_LENGTH = 150

    def self.plain_text(markdown)
      html = MarkdownRenderer.render(markdown)
      html.gsub(/<[^>]+>/, " ")
        .gsub(/\s+/, " ")
        .strip
    end

    def self.build(body, length: DEFAULT_LENGTH)
      text = plain_text(body)
      return [text, false] if text.length <= length

      ["#{text[0, length]}…", true]
    end
  end
end
