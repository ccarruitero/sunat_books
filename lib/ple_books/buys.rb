# frozen_string_literal: true

require_relative "base"

module PleBooks
  class Buys < Base
    def initialize(ruc, tickets, month, year, options = {})
      # ruc => company's ruc in string format
      # tickets => an array of objects that respond to a layout's methods
      # month => a number that represent a month
      # year => a number that represent a year
      # options =>
      #   :yml  => to define a custom layout file
      #   :layout => to define a custom name for a specific layout method

      book_name = self.class.name.downcase.sub("plebooks::", "")
      dir = File.dirname(__FILE__)
      yml_path = options[:yml] || "#{dir}/layouts/#{book_name}.yml"
      fields = YAML.load_file(yml_path)
      check_layout(options, fields)
      content = !tickets.empty? ? 1 : 0
      name = ple_book_name("8.1", ruc, month, year, nil, content)

      filename = "#{path}#{name}.txt"
      get_file(tickets, fields, filename)
    end

    def insert_layout_fields(options, fields)
      options[:layout].each do |key, value|
        i = fields.index(key.to_s)
        fields.delete(key.to_s)
        fields.insert(i, value)
      end
    end
  end
end
