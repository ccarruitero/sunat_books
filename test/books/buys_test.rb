# frozen_string_literal: true

require_relative "../helper"
require "sunat_books/books/pages_utils"

include PagesUtils

setup do
  @company = Company.new(ruc: Faker::Number.number(11), name: Faker::Name.name)
end

test "render pdf, have a parseable pdf" do
  tickets = []
  pdf = Books::Buys.new(@company, tickets, 2, 3015)
  page_counter = PDF::Inspector::Page.analyze(pdf.render)
  assert pdf.page_count == 1
  assert page_counter.pages.size == 1
end

test "@book_name instance variable is correct" do
  book = Books::Buys.new(@company, [], 2, 3015)
  assert_equal book.instance_variable_get("@book_name"), "buys"
end

test "have correct text in header" do
  tickets = []
  pdf = Books::Buys.new(@company, tickets, 2, 3015)
  reader = PDF::Reader.new(StringIO.new(pdf.render))
  assert reader.pages.first.text.include?("REGISTRO DE COMPRAS")
end

test "#page_not_full return a page" do
  pages = []
  setup_pages(pages, 20, 5)
  first = pages.at(1)
  page = page_not_full(first, pages, 20)
  assert_equal page.class, Books::Page
end

test "#page_not_full return last page when length is less than page_max" do
  pages = []
  setup_pages(pages, 20, 5)
  first_page = pages.at(1)
  page = page_not_full(first_page, pages, 5)
  assert_equal page, first_page
end

test "#page_not_full return new page when last page is full" do
  pages = []
  setup_pages(pages, 20, 5)
  first_page = pages.at(1)
  first_page.length += 5
  current_page = pages.at(2)
  page = page_not_full(first_page, pages, 5)
  assert_equal page, current_page
  assert_equal page.page_number, 2
end

test "#row_data prepare data that will be include in table's rows" do
end
