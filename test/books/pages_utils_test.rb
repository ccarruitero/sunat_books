# frozen_string_literal: true

require_relative "../helper"
require_relative "../../lib/books/pages_utils"
require_relative "../../lib/books/page"

include PagesUtils

test "#setup_pages generate new pages to fill all elements" do
  pages = []
  setup_pages(pages, 20, 10)
  # since array index is used to match page position for buys, and is same as
  # page_number, we have an extra index
  assert_equal pages.count, 3

  page = pages.last
  assert_equal page.page_number, 2
  assert_equal page.bi_sum, BigDecimal(0)

  other = []
  setup_pages(other, 29, 27)
  assert_equal other.count, 3
end

test "#setup_pages generate new pages without extra page" do
  pages = []
  setup_pages(pages, 20, 10, 0)
  assert_equal pages.count, 2
end

test "#setup_new_page copy page sums into current page" do
  pages = []
  setup_pages(pages, 52, 27)
  page = pages[1]
  page.bi_sum += BigDecimal(20)
  new_page = setup_new_page(pages, page, 1)
  assert_equal new_page.bi_sum, page.bi_sum
end

test "#page_index should get a page index according index and page_max" do
  assert_equal page_index(20, 20), 1
  assert_equal page_index(30, 20), 2
  assert_equal page_index(20, 7), 3
  assert_equal page_index(0, 7), 1
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

test "#split_data, split data for more than one array" do
  data = []
  (1..3).map do
    row = []
    (1..29).map { row << "foo" }
    data << row
  end
  pages = split_data(data, 20)
  assert_equal pages.count, 2
  assert_equal pages[0].data.last.count, 19
  assert_equal pages[1].data.last.count, 11
  assert_equal pages[0].data.first.count, 20
  assert_equal pages[1].data.first.count, 11
end

test "#split_data, split in more than 2 arrays" do
  row = []
  (1..49).map { row << "foo" }
  pages = split_data([row], 20)
  assert_equal pages.count, 3
  assert pages[2].data.count.positive?
end