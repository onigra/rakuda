# frozen_string_literal: true

require "date"
require "rakuda/config"
require "rakuda/markdown_renderer"
require "rakuda/site_context"
require "rakuda/template_renderer"

module Factories
  class PostFactory
    def self.build_post(overrides = {})
      defaults = {
        title: "Post",
        slug: "post",
        date: Date.new(2026, 1, 1),
        categories: ["ruby"],
        draft: false,
        body: "Body",
        url: "/blog/2026/01/01/post/",
        summary: "Summary"
      }

      Rakuda::Models::Post.new(**defaults.merge(overrides))
    end
  end
end
