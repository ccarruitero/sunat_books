# frozen_string_literal: true

require_relative "../helper"
require "sunat_books/pdf/utils"

include Utils

setup do
  @widths = [{ xyz: [20, 23], abc: [41] }]
  @column_widths = get_column_widths(@widths, :xyz)
end

test "#get_column_widths return an empty obj when dont match key" do
  column_widths = get_column_widths(@widths, :xyc)
  assert column_widths.is_a?(Hash)
end

test "#get_column_widths return an array with widths when match key" do
  assert @column_widths.is_a?(Array)
end

test "#add_widths set column width in options" do
  opt = { cell_style: {} }
  add_widths(@column_widths, opt, 15)
  assert opt[:cell_style].empty?
  assert opt[:column_widths]
end

test "#add_widths set cell width in options" do
  opt = { cell_style: {} }
  add_widths({}, opt, 15)
  assert opt[:cell_style][:width] == 15
end

test "#field_value return a value for a given attribute" do
  ticket = Ticket.new(foo: "bar")
  assert_equal field_value(ticket, "foo"), "bar"
  assert_equal field_value(ticket, "bar"), ""
end

test "#sum_count" do
end

test "#order_data_row" do
end

test "#get_row_sums" do
end
