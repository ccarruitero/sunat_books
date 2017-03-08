# frozen_string_literal: true
require "books/base"
require "books/count_sum"

module Books
  class SimplifiedDiary < Base
    def initialize(company, tickets, view, month, year)
      super(page_layout: :landscape, margin: [5], page_size: "A4")
      @view = view
      @company = company
      @tickets = tickets
      # @book_name = self.class.name.downcase.sub("books::", "")
      # dir = File.dirname(__FILE__)
      # @blayout = YAML.load_file("#{dir}/layouts/#{@book_name}.yml")
      counts = get_mother_counts @tickets
      total_sums = counts.map { |count| CountSum.new(count) }

      (month.to_i..12).each do |m|
        start_new_page unless m == month.to_i
        period = get_period(m, year)

        bounding_box([bounds.left + 3, bounds.top - 10], width: 815, height: 510) do
          book_body m, year, total_sums, 20, period
        end
      end
    end

    def book_body(month, year, total_sums, max_column = nil, period = nil)
      data = []
      tickets = @tickets.where(period_month: month, period_year: year)

      # header
      # counts = get_counts @tickets
      counts = get_mother_counts @tickets
      data << ["FECHA", "OPERACIÓN", counts].flatten

      # body

      # initial entry
      initial = tickets.where(operation_type: "inicial")
      if !initial.empty?
        initial_data = get_row_sums(initial, counts, total_sums)
      else
        initial_data = []
        total_sums.map do |sum|
          initial_data << { content: formated_number(sum.total), align: :right }
        end
      end
      date = get_date(year.to_i, month.to_i, 1)
      data << [date, "ASIENTO INICIAL DEL PERIODO", initial_data].flatten

      if !tickets.empty?
        sales = tickets.where(operation_type: "ventas")
        if sales.count.positive?
          # sales entry
          sales_sum = get_row_sums(sales, counts, total_sums)
          sales_row = [get_date(year.to_i, month.to_i, -1), "VENTAS DEL PERIODO", sales_sum].flatten
          data << sales_row
        end

        buys = tickets.where(operation_type: "compras")
        if buys.count.positive?
          # buys entry
          buys_row = get_row_sums(buys, counts, total_sums)
          data << [get_date(year.to_i, month.to_i, -1), "COMPRAS DEL PERIODO", buys_row].flatten
        end

        # other entries
        others = tickets.where(operation_type: "otros")
        # others_row = get_row_sums(others, counts, total_sums)
        others.each do |ticket|
          ticket_data = []
          counts.each_with_index do |count, i|
            if ticket.uniq_mother_counts.include? count
              value = get_value(ticket, count)
            else
              value = 0
            end
            total_sums[i].add value
            ticket_data << { content: formated_number(value), align: :right }
          end
          data << [parse_day(ticket.operation_date), ticket.reference, ticket_data].flatten
        end

        # cierre entry
        close = tickets.where(operation_type: "cierre")
        close.each do |ticket|
          ticket_data = []
          counts.each_with_index do |count, i|
            value = ticket.uniq_mother_counts.include?(count) ? get_value(ticket, count) : 0
            total_sums[i].add value
            ticket_data << { content: formated_number(value), align: :right }
          end
          data << [parse_day(ticket.operation_date), ticket.reference, ticket_data].flatten
        end
      else
        data << [{ content: "SIN MOVIMIENTO EN EL PERIODO", colspan: 5 }]
      end

      # totals
      total_data = []
      total_sums.map do |sum|
        total_data << { content: formated_number(sum.total), align: :right }
      end
      data << [{ content: "TOTALES", colspan: 2 }, total_data].flatten

      book_header period, @company.ruc, @company.name, "LIBRO DIARIO - FORMATO SIMPLIFICADO"

      if data.first.count > max_column
        tmp0 = []
        tmp1 = []

        data.each do |column|
          if column == data.last
            first_page = column.first(max_column - 1)
            second_page = (column[(max_column - 1)..column.length])
            tmp0 << first_page
            next_page = [column.first] + second_page
            tmp1 << next_page
          elsif column.length < max_column
            tmp0 << column
          else
            first_page = column.first(max_column)
            tmp0 << first_page

            # TODO: make the same for more than 2 pages
            next_page = column.first(2) + (column[max_column..column.length])
            tmp1 << next_page
          end
        end

        table(tmp0, header: true, cell_style: { borders: [], size: 6 },
                    column_widths: { 1 => 73 })
        start_new_page
        book_header period, @company.ruc, @company.name, "LIBRO DIARIO - FORMATO SIMPLIFICADO"
        table(tmp1, header: true, cell_style: { borders: [], size: 6 },
                    column_widths: { 1 => 73 })

      else

        table(data, header: true, cell_style: { borders: [], size: 6 },
                    column_widths: { 1 => 73 })
      end
    end
  end
end
