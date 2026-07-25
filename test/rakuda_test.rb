# frozen_string_literal: true

require "test_helper"

class RakudaTest < Test::Unit::TestCase
  test "VERSION" do
    assert do
      ::Rakuda.const_defined?(:VERSION)
    end
  end

  test "something useful" do
    assert_equal("expected", "actual")
  end
end
