# frozen_string_literal: true

require_relative "../helper"

setup do
  @tickets = [{}]
  @ruc = "102392839213"
end

test "generate txt file" do
  ple = SunatBooks::Ple::Sales.new(@ruc, @tickets, 10, 2013)
  assert File.exist?(ple.file)
end

test "allow define book format" do
  options = { book_format: "14.1" }
  ple = SunatBooks::Ple::Sales.new(@ruc, @tickets, 10, 2013, options)
  assert File.exist?(ple.file)
  assert ple.book_format, "14.1"
end
