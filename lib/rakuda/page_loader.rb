# frozen_string_literal: true

require "time"
require_relative "front_matter"
require_relative "models/page"

module Rakuda
  class PageLoader
    def self.load(source_dir)
      new(source_dir).load
    end

    def initialize(source_dir)
      @source_dir = source_dir
    end

    def load
      path = File.join(@source_dir, "content", "about.md")
      return [] unless File.exist?(path)

      [build(path)]
    end

    private

    def build(path)
      front, body = FrontMatter.parse_file(path)
      summary, = FrontMatter.split_summary(body)

      Models::Page.new(
        title: front.fetch("title"),
        url: front.fetch("url"),
        body: body,
        date: front["date"] ? Time.parse(front["date"].to_s) : nil,
        categories: Array(front["categories"]),
        summary: summary,
        content: nil
      )
    end
  end
end
