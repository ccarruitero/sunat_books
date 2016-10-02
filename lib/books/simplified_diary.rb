require 'books/base'
require 'books/count_sum'

module Books
  class SimplifiedDiary < Base
    def initialize company, tickets, view, month, year
      super(page_layout: :landscape, margin: [5], page_size: "A4")
      @view = view
      @company = company
      @tickets = tickets
      #@book_name = self.class.name.downcase.sub("books::", "")
      #dir = File.dirname(__FILE__)
      #@blayout = YAML.load_file("#{dir}/layouts/#{@book_name}.yml")
      counts = get_counts @tickets
      total_sums = counts.map { |count| CountSum.new(count) }

      (month.to_i..12).each do |m|
        start_new_page unless m == month.to_i
        period = get_period(m, year)
        #repeat(:all) do
        #  canvas do
        bounding_box([bounds.left + 10, bounds.top - 10], width: 800) do
          book_title "LIBRO DIARIO - FORMATO SIMPLIFICADO"
          book_header period, @company.ruc, @company.name
        end
        #  end
        #end

        bounding_box([bounds.left + 3, bounds.top - 45], width: 790, height: 510) do
          book_body m, year, total_sums
        end
      end
    end

    def book_body month, year, total_sums
      data = []
      tickets = @tickets.where(period_month: month, period_year: year)

      # header
      counts = get_counts @tickets
      data << ['FECHA', 'OPERACIÓN', counts].flatten

      # body

      # initial entry
      initial = tickets.where(operation_type: 'inicial')
      if initial.length > 0
        initial_data = get_row_sums(initial, counts, total_sums)
      else
        initial_data = []
        total_sums.map do |sum|
          initial_data << { content: formated_number(sum.total), align: :right }
        end
      end
      data << [Date.new(year.to_i, month.to_i, 1).to_s, 'ASIENTO INICIAL DEL PERIODO', initial_data].flatten

      if tickets.length > 0
        # sales entry
        sales = tickets.where(operation_type: 'ventas')
        sales_row = get_row_sums(sales, counts, total_sums)
        data << [Date.new(year.to_i, month.to_i, -1).to_s, 'VENTAS DEL PERIODO', sales_row].flatten

        # buys entry
        buys = tickets.where(operation_type: 'compras')
        buys_row = get_row_sums(buys, counts, total_sums)
        data << [Date.new(year.to_i, month.to_i, -1).to_s, 'COMPRAS DEL PERIODO', buys_row].flatten

        # other entries
        others = tickets.where(operation_type: 'otros')
        others.each do |ticket|
          ticket_data = []
          counts.each_with_index do |count, i|
            if uniq_counts(ticket).include? count
              value = get_value(ticket, count)
            else
              value = 0
            end
            total_sums[i].add value
            ticket_data << { content: formated_number(value), align: :right }
          end
          data << [ticket.operation_date, ticket.reference, ticket_data].flatten
        end
      else
        data << [{content: 'SIN MOVIMIENTO EN EL PERIODO', colspan: 5}]
      end

      # totals
      total_data = []
      total_sums.map do |sum|
        total_data << { content: formated_number(sum.total), align: :right }
      end
      data << [{content: 'TOTALES', colspan: 2}, total_data].flatten

      table(data, header: true, cell_style: {borders: [], size: 6})
    end
  end
end
