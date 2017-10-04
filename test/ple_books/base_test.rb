# frozen_string_literal: true

require_relative "helper"

setup do
  @base = SunatBooks::Ple::Base.new
end

test "book_code" do
  assert @base.book_code("8.1") == "080100"
  assert @base.book_code("3.1") == "030100"
end

test "ple_book_name" do
  name = @base.ple_book_name("8.1", "10201902912", 2015, 11)
  assert name.length == 33

  name = @base.ple_book_name("8.1", "10201902912", 2015, 11, nil, 0)
  assert name.length == 33
  assert name[30] == "0"

  name = @base.ple_book_name("8.1", "10201902912", 2015, 11, nil, nil, 2)
  assert name.length == 33
  assert name[31] == "2"
end

test "get_file" do
  fields = []
  3.times { fields << random_string(String.public_methods) }

  tickets = []
  3.times do
    hash = {}
    fields.each { |field| hash.merge!("#{field}": SecureRandom.hex(2)) }
    tickets << Ticket.new(hash)
  end

  filename = "#{@base.path}/some_file.txt"
  @base.get_file(tickets, fields, filename)

  assert File.exist?(filename)

  file_str = File.read(filename)
  assert file_str.count("\n") == 3
  assert file_str.split("\n").first == get_line(fields, tickets.first)
  assert file_str.split("\n").last == get_line(fields, tickets.last)
end
