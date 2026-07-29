# frozen_string_literal: true

module Rakuda
  module Models
    Post = Data.define(:title, :slug, :date, :categories, :draft, :body, :url, :summary, :has_more)
  end
end
