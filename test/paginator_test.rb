# frozen_string_literal: true

require "test_helper"
require "rakuda/paginator"

class TestPaginator < Test::Unit::TestCase
  def test_paginate_splits_25_items_into_3_pages
    # Given
    # 25 items を 10件 ずつページネート
    items = (1..25).to_a
    per_page = 10

    # When
    pages = Rakuda::Paginator.paginate(items, per_page: per_page)

    # Then
    # 3 pages
    assert_equal 3, pages.size

    # 1ページ目は10件
    assert_equal 10, pages[0].items.size
    # 2ページ目は10件
    assert_equal 10, pages[1].items.size
    # 3ページ目は5件
    assert_equal 5, pages[2].items.size

    # 1ページ目のページ番号は1
    assert_equal 1, pages[0].number
    # 2ページ目のページ番号は2
    assert_equal 2, pages[1].number
    # 3ページ目のページ番号は3
    assert_equal 3, pages[2].number

    # 1ページ目の総ページ数は3
    assert_equal 3, pages[0].total
    # 3ページ目の総ページ数は3
    assert_equal 3, pages[2].total
  end

  def test_paginate_empty_items
    pages = Rakuda::Paginator.paginate([], per_page: 10)

    assert_equal 0, pages.size
  end

  def test_paginate_exact_page_boundary
    # Given
    # 20 items を 10件 ずつページネート（ちょうど割り切れる）
    items = (1..20).to_a
    per_page = 10

    # When
    pages = Rakuda::Paginator.paginate(items, per_page: per_page)

    # Then
    # 2 pages
    assert_equal 2, pages.size

    # 1ページ目は10件
    assert_equal 10, pages[0].items.size
    # 2ページ目は10件
    assert_equal 10, pages[1].items.size

    # 1ページ目のページ番号は1
    assert_equal 1, pages[0].number
    # 2ページ目のページ番号は2
    assert_equal 2, pages[1].number

    # 1ページ目の総ページ数は2
    assert_equal 2, pages[0].total
    # 2ページ目の総ページ数は2
    assert_equal 2, pages[1].total
  end

  def test_paginate_single_page
    # Given
    # 5 items を 10件 ずつページネート（1ページに収まる）
    items = (1..5).to_a
    per_page = 10

    # When
    pages = Rakuda::Paginator.paginate(items, per_page: per_page)

    # Then
    # 1 page
    assert_equal 1, pages.size

    # 1ページ目は5件
    assert_equal 5, pages[0].items.size

    # 1ページ目のページ番号は1
    assert_equal 1, pages[0].number

    # 1ページ目の総ページ数は1
    assert_equal 1, pages[0].total
  end
end
