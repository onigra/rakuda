# frozen_string_literal: true

require_relative "models/contents"
require_relative "post_loader"
require_relative "page_loader"

module Rakuda
  class ContentLoader
    def self.load(source_dir, config)
      Models::Contents.new(
        posts: PostLoader.load(source_dir, config),
        pages: PageLoader.load(source_dir, config)
      )
    end
  end
end
