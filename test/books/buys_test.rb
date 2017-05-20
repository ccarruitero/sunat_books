# frozen_string_literal: true

require_relative "../helper"

setup do
  @company = Company.new(ruc: Faker::Number.number(11), name: Faker::Name.name)
end

test "render pdf, have a parseable pdf" do
  tickets = []
  view = Object.new.tap { |o| o.extend(Prawn::View) }
  pdf = Books::Buys.new(@company, tickets, view, 2, 3015)
  page_counter = PDF::Inspector::Page.analyze(pdf.render)
  assert pdf.page_count == 1
  assert page_counter.pages.size == 1
end

test "have correct text in header" do
  tickets = []
  view = Object.new.tap { |o| o.extend(Prawn::View) }
  pdf = Books::Buys.new(@company, tickets, view, 2, 3015)
  # pdf_analyzed = PDF::Inspector::Text.analyze(pdf.render)
  # puts pdf_analyzed.strings
  reader = PDF::Reader.new(StringIO.new(pdf.render))
  assert reader.pages.first.text.include?("REGISTRO DE COMPRAS")
end
