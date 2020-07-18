# frozen_string_literal: true

require "csv"
require_relative "option_error"
require_relative "../common_utils"

module SunatBooks
  module Csv
    class Base
      include SunatBooks::CommonUtils

      attr_accessor :file

      def initialize(tickets, options = {})
        # options
        # - layout => Array of strings used to get data for csv
        # - filename
        raise SunatBooks::Csv::OptionError, "Layout option is required" if options[:layout].nil?

        filename = options[:filename] || "#{tmp_path}book.csv"
        fields = options[:layout]
        get_file(filename, fields, tickets)
      end

      def get_file(filename, fields, tickets)
        send("file=", filename)
        File.exist?(filename) ? File.delete(filename) : nil
        FileUtils.touch(filename)
        append_headers(filename, fields)
        append_data(tickets, filename, fields)
      end

      def tmp_path
        dir = File.dirname(__FILE__)
        tmp_path = "#{dir}/tmp/"
        Dir.mkdir(tmp_path) unless Dir.exist?(tmp_path)
        tmp_path
      end

      def append_headers(filename, fields)
        append_to_csv(filename, fields, "w+")
      end

      def append_data(tickets, filename, fields)
        tickets&.each do |ticket|
          data = []
          fields&.each do |field|
            data << available_value?(ticket, field)
          end
          append_to_csv(filename, data, "a+")
        end
      end

      def append_to_csv(filename, data, mode)
        return if data.nil?

        CSV.open(filename, mode) do |csv|
          csv << data
        end
      end
    end
  end
end
