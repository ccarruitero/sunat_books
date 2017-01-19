require 'csv'

module PleBooks
  class Base
    attr_accessor :file

    def ple_book_name uid, ruc, month, year, operations_state=nil, content=nil, currency=nil
      code = book_code(uid)
      code_oportunity = '00' # TODO: case for 'inventarios y balances'
      operations_state ||= 1 # 0, 1, 2
      content ||= 1 # 1 ,0
      currency ||= 1 # 1, 2
      "LE#{ruc}#{year}#{month}00#{code}#{code_oportunity}#{operations_state}#{content}#{currency}1"
    end

    def book_code uid
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
      Dir.mkdir(tmp_path) unless Dir.exists?(tmp_path)
      tmp_path
    end

    def get_file(tickets, fields, filename)
      FileUtils.touch("#{filename}")

      send("file=", filename)

      tickets.each_with_index do |ticket, i|
        ticket_data = ""

        fields.each do |field|
          begin
            value = ticket.send(field)
          rescue
            value = ""
          end
          ticket_data << "#{value}|"
        end

        mode = (i == 0 ? "w+" : "a+")
        File.open("#{filename}", mode) do |txt|
          txt.puts(ticket_data)
        end
      end
    end
  end
end
