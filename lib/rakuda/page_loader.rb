# frozen_string_literal: true

require "time"
require_relative "front_matter"
require_relative "excerpt"
require_relative "models/page"

module Rakuda
  class PageLoader
    def self.load(source_dir, config)
      path = File.join(source_dir, "content", "about.md")
      return [] unless File.exist?(path)

      [build(path, config)]
    end

    def self.build(path, config)
      front, body = FrontMatter.parse_file(path)
      summary, has_more = Excerpt.build(body, length: config.summary_length)

      Models::Page.new(
        title: front.fetch("title"),
        url: front.fetch("url"),
        body: body,
        date: front["date"] ? Time.parse(front["date"].to_s) : nil,
        categories: Array(front["categories"]),
        summary: summary,
        has_more: has_more,
        content: nil
      )
    end
    private_class_method :build
  end
end
