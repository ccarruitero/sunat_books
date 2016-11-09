require 'ple_books/base'

module PleBooks
  class Buys < Base
    def initialize(ruc, tickets, month, year)
      book_name = self.class.name.downcase.sub("plebooks::", "")
      dir = File.dirname(__FILE__)
      fields = YAML.load_file("#{dir}/layouts/#{book_name}.yml")

      @filename = "#{path}#{ple_book_name('8.1', ruc, month, year)}.txt"
      get_file(tickets, fields, @filename)
    end
  end
end
