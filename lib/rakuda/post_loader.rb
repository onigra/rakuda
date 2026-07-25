# frozen_string_literal: true

require "time"
require_relative "front_matter"
require_relative "url_generator"
require_relative "models/post"

module Rakuda
  class PostLoader
    DEFAULT_PERMALINK_POST = "/:year/:month/:day/:slug/"

    def self.load(source_dir, config)
      new(source_dir, config).load
    end

    def initialize(source_dir, config)
      @source_dir = source_dir
      permalink = config.permalink_post || DEFAULT_PERMALINK_POST
      @url_gen = UrlGenerator.new(permalink)
    end

    def load
      dir = File.join(@source_dir, "content", "post")
      return [] unless Dir.exist?(dir)

      Dir.glob(File.join(dir, "*.md")).map { |path| build(path) }
        .reject(&:draft)
        .sort_by(&:date).reverse
    end

    private

    def build(path)
      front, body = FrontMatter.parse_file(path)
      date = Time.parse(front.fetch("date").to_s)
      slug = front.fetch("slug")
      summary, = FrontMatter.split_summary(body)

      Models::Post.new(
        title: front.fetch("title"),
        slug: slug,
        date: date,
        categories: Array(front["categories"]),
        draft: front["draft"] == true,
        body: body,
        url: @url_gen.post_url(date, slug),
        summary: summary
      )
    end
  end
end
