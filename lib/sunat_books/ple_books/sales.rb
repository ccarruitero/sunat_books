# frozen_string_literal: true

require "sunat_books/ple_books/base"

module PleBooks
  class Sales < Base
    def initialize(ruc, tickets, month, year, options = {})
      book_name = self.class.name.downcase.sub("plebooks::", "")
      dir = File.dirname(__FILE__)
      yml_path = options[:yml] || "#{dir}/layouts/#{book_name}.yml"
      fields = YAML.load_file(yml_path)
      check_layout(options, fields)
      content = !tickets.empty? ? 1 : 0

      name = ple_book_name("14.2", ruc, month, year, nil, content)
      @filename = "#{path}#{name}.txt"
      get_file(tickets, fields, @filename)
    end
  end
end
