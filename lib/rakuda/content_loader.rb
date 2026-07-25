# frozen_string_literal: true

require "front_matter_parser"
require "time"
require "date"
require_relative "url_generator"

module Rakuda
  LoadResult = Data.define(:posts, :pages)

  class ContentLoader
    YAML_LOADER = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Time, Date])
    PARSER = FrontMatterParser::Parser.new(:md, loader: YAML_LOADER)

    def self.load(source_dir, config)
      new(source_dir, config).load
    end

    def initialize(source_dir, config)
      @source_dir = source_dir
      @config = config
      @url_gen = UrlGenerator.new(config.permalink_post)
    end

    def load
      posts = load_posts
      pages = load_pages
      LoadResult.new(posts: posts, pages: pages)
    end

    private

    def load_posts
      dir = File.join(@source_dir, "content", "post")
      return [] unless Dir.exist?(dir)

      Dir.glob(File.join(dir, "*.md")).map { |path| build_post(path) }
        .reject(&:draft)
        .sort_by(&:date).reverse
    end

    def load_pages
      path = File.join(@source_dir, "content", "about.md")
      return [] unless File.exist?(path)

      [build_page(path)]
    end

    def build_post(path)
      content = File.read(path)
      fm = PARSER.call(content)
      front = fm.front_matter
      body = fm.content
      date = Time.parse(front.fetch("date").to_s)
      slug = front.fetch("slug")
      summary, _rest = split_summary(body)

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

    def build_page(path)
      content = File.read(path)
      fm = PARSER.call(content)
      front = fm.front_matter
      body = fm.content
      summary, = split_summary(body)

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

    def split_summary(body)
      parts = body.split("<!--more-->", 2)
      (parts.length == 2) ? [parts[0].strip, parts[1].strip] : [body.strip, ""]
    end
  end
end
