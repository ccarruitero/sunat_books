# frozen_string_literal: true

require_relative "../helper"
require "sunat_books/csv_books/option_error"

setup do
  @tickets = []
  5.times do
    @tickets << Ticket.new(field: SecureRandom.hex(10))
  end
  @base = CsvBooks::Base.new(@tickets, layout: ["field"])
end

test "require a layout array" do
  assert_raise(CsvBooks::OptionError) { CsvBooks::Base.new(@tickets) }
end

test "should generate csv" do
  assert File.exist?(@base.file)
end

test "should allow set custom filename" do
  custom_file = CsvBooks::Base.new(@tickets, layout: [], filename: "name.csv")
  assert custom_file.file.include?("name.csv")
  assert File.exist?(custom_file.file)
end

test "should handle undefined layout method" do
  undefined_method = CsvBooks::Base.new(@tickets, layout: %w[field bar])
  assert File.exist?(undefined_method.file)
end

test "csv should have the correct row's count" do
  csv = CSV.open(@base.file, "r+")
  csv_rows = csv.readlines
  assert_equal csv_rows.count, 6
end

test "csv should contain headers in first row" do
  csv = CSV.open(@base.file, "r+")
  csv_rows = csv.readlines
  assert_equal csv_rows.first, ["field"]
end
