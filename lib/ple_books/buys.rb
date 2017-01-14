require 'ple_books/base'

module PleBooks
  class Buys < Base
    def initialize(ruc, tickets, month, year, yml=nil)
      book_name = self.class.name.downcase.sub("plebooks::", "")
      dir = File.dirname(__FILE__)
      yml_path = yml || "#{dir}/layouts/#{book_name}.yml"
      fields = YAML.load_file(yml_path)
      content = tickets.length > 0 ? 1 : 0

      @filename = "#{path}#{ple_book_name('8.1', ruc, month, year, nil, content)}.txt"
      get_file(tickets, fields, @filename)
    end
  end
end
