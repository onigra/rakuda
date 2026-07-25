require "yaml"
require "date"

module Rakuda
  Config = Data.define(
    :base_url, :title, :language, :author, :paginate,
    :permalink_post, :taxonomy_category, :params
  )
  class Config
    def self.load(path)
      data = YAML.safe_load_file(path, permitted_classes: [Date, Time], aliases: true)

      new(
        base_url: data.fetch("base_url"),
        title: data.fetch("title"),
        language: data.fetch("language", "ja"),
        author: data.fetch("author", ""),
        paginate: data.fetch("paginate", 10),
        permalink_post: data.dig("permalinks", "post"),
        taxonomy_category: data.dig("taxonomies", "category") || "categories",
        params: data.fetch("params", {})
      )
    end
  end
end
