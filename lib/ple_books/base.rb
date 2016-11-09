module PleBooks
  class Base
    def ple_book_name uid, ruc, month, year
      code = book_code(uid)
      "LE#{ruc}#{year}#{month}00#{code}001111"
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
      tickets.each do |ticket|
        ticket_data = ""

        fields.each do |field|
          begin
            value = ticket.send(field)
          rescue
            value = ""
          end
          ticket_data << "#{value}|"
        end

        File.open("#{filename}", "w+") do |txt|
          txt.write(ticket_data)
        end
      end
    end
  end
end
