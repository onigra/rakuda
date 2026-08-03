# frozen_string_literal: true

require "yaml"
require "date"
require_relative "excerpt"

module Rakuda
  Config = Data.define(
    :base_url, :title, :language, :author, :paginate, :summary_length,
    :permalink_post, :params
  )
  class Config
    def self.load(path)
      data = YAML.safe_load_file(path, permitted_classes: [Date, Time], aliases: true)
      default_params = {} #: Hash[untyped, untyped]

      new(
        base_url: data.fetch("base_url"),
        title: data.fetch("title"),
        language: data.fetch("language", "ja"),
        author: data.fetch("author", ""),
        paginate: data.fetch("paginate", 10),
        summary_length: data.fetch("summary_length", Excerpt::DEFAULT_LENGTH),
        permalink_post: data.dig("permalinks", "post"),
        params: data.fetch("params", default_params)
      )
    end
  end
end
