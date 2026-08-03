# frozen_string_literal: true

require_relative "rakuda/version"
require_relative "rakuda/config"
require_relative "rakuda/url_generator"
require_relative "rakuda/models/post"
require_relative "rakuda/models/page"
require_relative "rakuda/content_loader"
require_relative "rakuda/generators/post"
require_relative "rakuda/generators/home"
require_relative "rakuda/generators/section"
require_relative "rakuda/generators/rss"
require_relative "rakuda/generators/robots"
require_relative "rakuda/generators/page"
require_relative "rakuda/pipeline"

module Rakuda
  class Error < StandardError; end
  # Your code goes here...
end
