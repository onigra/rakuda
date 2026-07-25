# frozen_string_literal: true

require_relative "models/contents"
require_relative "post_loader"
require_relative "page_loader"

module Rakuda
  class ContentLoader
    def self.load(source_dir, config)
      new(source_dir, config).load
    end

    def initialize(source_dir, config)
      @source_dir = source_dir
      @config = config
    end

    def load
      Models::Contents.new(
        posts: PostLoader.load(@source_dir, @config),
        pages: PageLoader.load(@source_dir)
      )
    end
  end
end
