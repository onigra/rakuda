# frozen_string_literal: true

module Rakuda
  module Models
    Page = Data.define(:title, :url, :body, :date, :categories, :summary, :content)
  end
end
