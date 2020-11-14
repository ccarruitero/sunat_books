# frozen_string_literal: false

require "csv"
require_relative "../common_utils"
require_relative "./utils"

module SunatBooks
  module Ple
    class Base
      include SunatBooks::CommonUtils
      include Utils

      attr_accessor :file
      attr_reader :book_format

      # ruc => company's ruc in string format
      # tickets => an array of objects that respond to a layout's methods
      # month => a number that represent a month
      # year => a number that represent a year
      # options =>
      #   :yml  => to define a custom layout file
      #   :layout => to define a custom name for a specific layout method
      #   :book_format => to define ple book format to use
      def initialize(ruc, tickets, month, year, options = {})
        @book_format = options[:book_format]
        yml_path = options[:yml] || default_yml(book_format)
        raise SunatBooks::Errors::InvalidLayoutError unless File.exist?(yml_path)

        fields = YAML.load_file(yml_path)
        check_layout(options, fields)
        content = !tickets.empty? ? 1 : 0

        name = ple_book_name(book_format, ruc, month, year, nil, content)
        filename = "#{path}#{name}.txt"
        get_file(tickets, fields, filename)
      end

      private

      # get default yml file according book format given
      # book_format => ple book format
      def default_yml(book_format)
        book_name = self.class.name.downcase.sub("sunatbooks::ple::", "")
        dir = File.dirname(__FILE__)
        "#{dir}/layouts/#{book_name}-#{book_format}.yml"
      end
    end
  end
end
