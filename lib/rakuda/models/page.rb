# frozen_string_literal: true

module Rakuda
  module Models
    Page = Data.define(:title, :url, :body, :date, :summary, :has_more, :content)
  end
end
