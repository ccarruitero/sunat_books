# frozen_string_literal: false

require "csv"
require_relative "../common_utils"

module PleBooks
  class Base
    include SunatBooks::CommonUtils

    attr_accessor :file

    def ple_book_name(uid, ruc, month, year, *args)
      code = book_code(uid)
      code_oportunity = "00" # TODO: case for 'inventarios y balances'
      operations_state = args[0] || 1 # 0, 1, 2
      content = args[1] || 1 # 1 ,0
      currency = args[2] || 1 # 1, 2
      name = "LE#{ruc}#{year}#{month}00#{code}#{code_oportunity}"
      name << "#{operations_state}#{content}#{currency}1"
    end

    def book_code(uid)
      dir = File.dirname(__FILE__)
      path = "#{dir}/book_codes.csv"
      code = ""
      CSV.foreach(path) do |row|
        if row[0] == uid
          code = row[2]
          break
        end
      end
      code
    end

    def path
      dir = File.dirname(__FILE__)
      tmp_path = "#{dir}/tmp/"
      Dir.mkdir(tmp_path) unless Dir.exist?(tmp_path)
      tmp_path
    end

    def get_file(tickets, fields, filename)
      FileUtils.touch(filename.to_s)

      send("file=", filename)

      tickets.each_with_index do |ticket, i|
        ticket_data = get_value(fields, ticket)

        mode = (i.zero? ? "w+" : "a+")
        File.open(filename.to_s, mode) do |txt|
          txt.puts(ticket_data)
        end
      end
    end

    def get_value(fields, ticket)
      data = ""
      fields.each do |field|
        value = available_value?(ticket, field)
        data << "#{value}|"
      end
      data
    end

    def check_layout(options, fields)
      options[:layout]&.each do |key, value|
        i = fields.index(key.to_s)
        fields.delete(key.to_s)
        fields.insert(i, value)
      end
    end
  end
end
