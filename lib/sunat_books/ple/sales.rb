# frozen_string_literal: true

require "sunat_books/ple/base"

module SunatBooks
  module Ple
    class Sales < Base
      def initialize(ruc, tickets, month, year, options = {})
        @book_format = options[:book_format] || "14.2"
        yml_path = options[:yml] || default_yml(book_format)
        fields = YAML.load_file(yml_path)
        check_layout(options, fields)
        content = !tickets.empty? ? 1 : 0

        name = ple_book_name(book_format, ruc, month, year, nil, content)
        filename = "#{path}#{name}.txt"
        get_file(tickets, fields, filename)
      end

      private

      def default_yml(book_format)
        book_name = self.class.name.downcase.sub("sunatbooks::ple::", "")
        dir = File.dirname(__FILE__)
        "#{dir}/layouts/#{book_name}-#{book_format}.yml"
      end
    end
  end
end
