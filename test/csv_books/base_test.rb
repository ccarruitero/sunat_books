# frozen_string_literal: true

require_relative "../helper"
require "sunat_books/csv/option_error"

setup do
  @tickets = []
  5.times do
    @tickets << Ticket.new(field: SecureRandom.hex(10))
  end
  @base = SunatBooks::Csv::Base.new(@tickets, layout: ["field"])
end

test "require a layout array" do
  assert_raise(SunatBooks::Csv::OptionError) do
    SunatBooks::Csv::Base.new(@tickets)
  end
end

test "should generate csv" do
  assert File.exist?(@base.file)
end

test "should allow set custom filename" do
  options = { layout: [], filename: "name.csv" }
  custom_file = SunatBooks::Csv::Base.new(@tickets, options)
  assert custom_file.file.include?("name.csv")
  assert File.exist?(custom_file.file)
end

test "should handle undefined layout method" do
  undefined_method = SunatBooks::Csv::Base.new(@tickets, layout: %w[field bar])
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
