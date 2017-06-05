# frozen_string_literal: true

require_relative "../helper"
require_relative "../../lib/books/diary_calculations"

include DiaryCalculations

setup do
end

test "split_data, separates data in groups according max_column desired" do
  row = []
  (1..29).map { row << "foo" }
  columns = split_data([row], 20)
  assert_equal columns.class, Hash
  assert_equal columns.count, 2
  assert_equal columns["tmp0"].first.count, 19
  assert_equal columns["tmp1"].first.count, 11
end

test "split_data, split in more than 2 arrays" do
  row = []
  (1..49).map { row << "foo" }
  columns = split_data([row], 20)
  assert_equal columns.count, 3
  assert columns["tmp2"].length > 0
end
