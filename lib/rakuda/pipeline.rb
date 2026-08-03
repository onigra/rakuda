# frozen_string_literal: true

require_relative "output_writer"
require_relative "template_renderer"
require_relative "markdown_renderer"
require_relative "generators/page"

module Rakuda
  ###
  #
  # ブログ生成に必要なファイルを source から全て読み込んで
  # static contents に rendering して destination に吐き出す君
  #
  class Pipeline
    #: @rbs source: String
    #: @rbs destination: String
    #: @rbs return: Void
    def initialize(source:, destination:)
      @source = source
      @destination = destination
    end

    #: @rbs return: Void
    def run
      config = Config.load(File.join(@source, "site.yml"))
      loaded = ContentLoader.load(@source, config)
      writer = OutputWriter.new(@destination)
      renderer = TemplateRenderer.new(File.join(@source, "layouts"))
      markdown = MarkdownRenderer

      pages = [] #: Array[Hash[Symbol, String]]
      pages.concat Generators::Post.new(config:, posts: loaded.posts, renderer:, markdown:).generate
      pages.concat Generators::Home.new(config:, posts: loaded.posts, renderer:, markdown:).generate
      pages.concat Generators::Section.new(config:, posts: loaded.posts, renderer:, markdown:).generate
      loaded.pages.each do |page|
        pages << Generators::Page.new(config:, page:, renderer:, markdown:).generate
      end

      pages.each { |p| writer.write_page(p[:url], p[:content]) }
      writer.write_file("index.xml", Generators::Rss.new(config:, posts: loaded.posts, renderer:).generate)
      writer.write_file("robots.txt", Generators::Robots.new(config:).generate)
      writer.copy_static(File.join(@source, "static"))
    end
  end
end
