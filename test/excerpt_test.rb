# frozen_string_literal: true

require "test_helper"
require "rakuda/excerpt"

class TestExcerpt < Test::Unit::TestCase
  def test_strips_markdown
    body = "# Title\n\n**Bold** text here."
    summary, has_more = Rakuda::Excerpt.build(body, length: 100)

    assert_not_include(summary, "#")
    assert_not_include(summary, "**")
    assert_include(summary, "Bold")
    assert_equal false, has_more
  end

  def test_truncates_plain_text_to_length
    body = "あ" * 150
    summary, has_more = Rakuda::Excerpt.build(body, length: 100)

    assert_equal "#{"あ" * 100}…", summary
    assert_equal true, has_more
  end

  def test_short_text_is_not_truncated
    body = "Short post."
    summary, has_more = Rakuda::Excerpt.build(body, length: 100)

    assert_equal "Short post.", summary
    assert_equal false, has_more
  end
end
