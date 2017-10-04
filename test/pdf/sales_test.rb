# frozen_string_literal: true

require_relative "../helper"

setup do
  @company = Company.new(ruc: Faker::Number.number(11), name: Faker::Name.name)
end

test "render pdf, have a parseable pdf" do
  tickets = []
  pdf = SunatBooks::Pdf::Sales.new(@company, tickets, 2, 3015)
  page_counter = PDF::Inspector::Page.analyze(pdf.render)
  assert pdf.page_count == 1
  assert page_counter.pages.size == 1
end
