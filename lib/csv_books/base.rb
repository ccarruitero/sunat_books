# frozen_string_literal: true

require "csv"
require_relative "option_error"

module CsvBooks
  class Base
    attr_accessor :file

    def initialize(tickets, options = {})
      # options
      # - layout => Array of strings used to get data for csv
      # - filename
      if options[:layout].nil?
        raise CsvBooks::OptionError.new(msg: "Layout option is required")
      end
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
          data << field_value(ticket, field)
        end
        append_to_csv(filename, data, "a+")
      end
    end

    def field_value(ticket, field)
      begin
        value = ticket.send(field)
      rescue
        value = ""
      end
      value
    end

    def append_to_csv(filename, data, mode)
      return if data.nil?
      CSV.open(filename, mode) do |csv|
        csv << data
      end
    end
  end
end
