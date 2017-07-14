# frozen_string_literal: true

require_relative "../helper"
require_relative "../../lib/books/diary_calculations"

include DiaryCalculations

setup do
end

test "#split_data, separates data in groups according max_column desired" do
  row = []
  (1..29).map { row << "foo" }
  pages = split_data([row], 20)
  assert_equal pages.class, Array
  assert_equal pages.count, 2
  assert_equal pages[0].data.first.count, 19
  assert_equal pages[1].data.first.count, 11
end

test "#split_data, split in more than 2 arrays" do
  row = []
  (1..49).map { row << "foo" }
  pages = split_data([row], 20)
  assert_equal pages.count, 3
  assert pages[2].data.count.positive?
end

test "#setup_row_pages" do
end
