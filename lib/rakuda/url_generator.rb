# frozen_string_literal: true

module Rakuda
  class UrlGenerator
    ###
    #
    # @param permalink_pattern [String] 記事の URL パターン
    # @return [void]
    #
    def initialize(permalink_pattern)
      @pattern = permalink_pattern
    end

    ###
    #
    # @param date [Date] 記事の日付
    # @param slug [String] 記事のスラッグ
    # @return [String] 記事の URL
    #
    def post_url(date, slug)
      @pattern
        .gsub(":year", date.strftime("%Y"))
        .gsub(":month", date.strftime("%m"))
        .gsub(":day", date.strftime("%d"))
        .gsub(":slug", slug)
    end

    ###
    #
    # トップページ（記事一覧）のページネーション用 URL を返すメソッド
    # ブログのトップページは記事が増えると複数ページに分割される
    # このメソッドは「何ページ目か」から、そのページの URL パスを決める
    #
    # | page_num | 返るURL | 意味               |
    # | -------- | -------- | ---------------- |
    # | 1        | /        | 1 ページ目（トップ）|
    # | 2        | /page/2/ | 2 ページ目        |
    # | 3        | /page/3/ | 3 ページ目        |
    #
    # @param page_num [Integer] ページ番号
    # @return [String] ページネーション用 URL
    #
    def home_page_url(page_num)
      (page_num <= 1) ? "/" : "/page/#{page_num}/"
    end
  end
end
