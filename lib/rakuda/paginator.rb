# frozen_string_literal: true

module Rakuda
  module Paginator
    PaginatedPage = Data.define(:items, :number, :total)

    ###
    #
    # @param items [Array] ページネートするアイテムの配列
    # @param per_page [Integer] 1ページあたりのアイテム数
    # @return [Array<PaginatorPage>]
    #
    def self.paginate(items, per_page:)
      pages = items.each_slice(per_page).to_a
      total = pages.size
      pages.each_with_index.map do |slice, idx|
        PaginatedPage.new(items: slice, number: idx + 1, total: total)
      end
    end
  end
end
