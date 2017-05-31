# frozen_string_literal: true

require_relative "base"
require_relative "count_sum"
require_relative "diary_entries"

module Books
  class SimplifiedDiary < Base
    include DiaryEntries
    def initialize(company, tickets, view, month, year)
      super(page_layout: :landscape, margin: [5], page_size: "A4")
      @view = view
      @company = company
      @tickets = tickets
      # @book_name = self.class.name.downcase.sub("books::", "")
      # dir = File.dirname(__FILE__)
      # @blayout = YAML.load_file("#{dir}/layouts/#{@book_name}.yml")

      prawn_book(month, year)
    end

    def prawn_book(month, year)
      (month.to_i..12).each do |m|
        start_new_page unless m == month.to_i
        period = get_period(m, year)

        x = bounds.left + 3
        y = bounds.top - 10
        bounding_box([x, y], width: 815, height: 510) do
          book_body m, year, 20, period
        end
      end
    end

    def book_body(month, year, max_column = nil, period = nil)
      tickets = @tickets.where(period_month: month, period_year: year)
      @main_title = "LIBRO DIARIO - FORMATO SIMPLIFICADO"
      counts = get_mother_counts @tickets
      total_sums = counts.map { |count| CountSum.new(count) }

      # header
      data = []
      data << ["FECHA", "OPERACIÓN", counts].flatten

      # body
      initial_data = initial_entry(tickets, counts, total_sums)
      date = get_date(year.to_i, month.to_i, 1)
      data << [date, "ASIENTO INICIAL DEL PERIODO", initial_data].flatten

      if !tickets.empty?
        period_date = get_date(year, month, -1)
        entries_data(tickets, counts, total_sums, data, period_date)
      else
        data << [{ content: "SIN MOVIMIENTO EN EL PERIODO", colspan: 5 }]
      end

      total_entry(total_sums, data)
      book_header period, @company.ruc, @company.name, @main_title

      draw_table(data, max_column, period)
    end

    def entries_data(tickets, counts, total_sums, data, period_date)
      sales_sum = sales_entry(tickets, counts, total_sums)
      title = "VENTAS DEL PERIODO"
      sales_row = [period_date, title, sales_sum].flatten
      data << sales_row

      buys_entry(tickets, counts, total_sums, data, period_date)
      other_entry(tickets, counts, total_sums, data)
      close_entry(tickets, counts, total_sums, data)
    end

    def draw_table(data, max_column, period)
      if data.first.count > max_column
        tmp0 = []
        tmp1 = []

        data.each do |column|
          if column == data.last
            first_page = column.first(max_column - 1)
            second_page = column[(max_column - 1)..column.length]
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

        render_prawn_table(tmp0)
        start_new_page
        book_header period, @company.ruc, @company.name, @main_title
        render_prawn_table(tmp1)

      else
        render_prawn_table(data)
      end
    end

    def render_prawn_table(data)
      table(data, header: true, cell_style: { borders: [], size: 6 },
                  column_widths: { 1 => 73 })
    end
  end
end
