# frozen_string_literal: true

require_relative "../helper"

setup do
  @company = Company.new(ruc: Faker::Number.number(11), name: Faker::Name.name)
end

test "render pdf, have a parseable pdf" do
  tickets = []
  pdf = SunatBooks::Pdf::Buys.new(@company, tickets, 2, 3015)
  page_counter = PDF::Inspector::Page.analyze(pdf.render)
  assert pdf.page_count == 1
  assert page_counter.pages.size == 1
end

test "@book_name instance variable is correct" do
  book = SunatBooks::Pdf::Buys.new(@company, [], 2, 3015)
  assert_equal book.instance_variable_get("@book_name"), "buys"
end

test "have correct text in header" do
  tickets = []
  pdf = SunatBooks::Pdf::Buys.new(@company, tickets, 2, 3015)
  reader = PDF::Reader.new(StringIO.new(pdf.render))
  assert reader.pages.first.text.include?("REGISTRO DE COMPRAS")
end
