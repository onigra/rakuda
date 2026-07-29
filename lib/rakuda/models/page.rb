# frozen_string_literal: true

module Rakuda
  module Models
    Page = Data.define(:title, :url, :body, :date, :categories, :summary, :has_more, :content)
  end
end
