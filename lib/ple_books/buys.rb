require 'ple_books/base'

module PleBooks
  class Buys < Base
    def initialize(ruc, tickets, month, year, options={})
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

      if options[:layout]
        options[:layout].each do |key, value|
          i = fields.index(key.to_s)
          fields.delete(key.to_s)
          fields.insert(i, value)
        end
      end

      content = tickets.length > 0 ? 1 : 0

      filename = "#{path}#{ple_book_name('8.1', ruc, month, year, nil, content)}.txt"
      get_file(tickets, fields, filename)
    end
  end
end
