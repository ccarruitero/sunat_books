# frozen_string_literal: true

require_relative "base"
require_relative "count_sum"
require_relative "diary_entries"
require_relative "diary_calculations"

module Books
  class SimplifiedDiary < Base
    include DiaryEntries
    include DiaryCalculations
    def initialize(company, tickets, view, month, year)
      super(page_layout: :landscape, margin: [5], page_size: "A4")
      @view = view
      @company = company
      @tickets = tickets
      # @book_name = self.class.name.downcase.sub("books::", "")
      # dir = File.dirname(__FILE__)
      # @blayout = YAML.load_file("#{dir}/layouts/#{@book_name}.yml")
      @main_title = "LIBRO DIARIO - FORMATO SIMPLIFICADO"
      @counts = get_mother_counts @tickets
      @total_sums = @counts.map { |count| CountSum.new(count) }

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

      # header
      data = []
      initial_day = get_date(year.to_i, month.to_i, 1)
      draw_table_header(tickets, @counts, @total_sums, data, initial_day)

      period_date = get_date(year, month, -1)
      entries_data(tickets, @counts, @total_sums, data, period_date)

      book_header period, @company.ruc, @company.name, @main_title
      draw_table_body(data, max_column, period)
    end

    def not_moviment_data(data)
      data << [{ content: "SIN MOVIMIENTO EN EL PERIODO", colspan: 5 }]
    end

    def entries_data(tickets, counts, total_sums, data, period_date)
      return not_moviment_data(data) if tickets.empty?
      sales_entry(tickets, counts, total_sums, data, period_date)
      buys_entry(tickets, counts, total_sums, data, period_date)
      other_entry(tickets, counts, total_sums, data)
      close_entry(tickets, counts, total_sums, data)
      total_entry(total_sums, data)
    end

    def draw_table_header(tickets, counts, total_sums, data, date)
      data << ["FECHA", "OPERACIÓN", counts].flatten

      # body
      initial_data = initial_entry(tickets, counts, total_sums)
      data << [date, "ASIENTO INICIAL DEL PERIODO", initial_data].flatten
    end

    def draw_table_body(data, max_column, period)
      return render_prawn_table(data) unless data.first.count > max_column

      pages = split_data(data, max_column)

      pages.each do |page|
        prawn_new_page(period) unless page.page_number.zero?
        render_prawn_table(page.data)
      end
    end

    def prawn_new_page(period)
      start_new_page
      book_header period, @company.ruc, @company.name, @main_title
    end

    def render_prawn_table(data)
      table(data, header: true, cell_style: { borders: [], size: 6 },
                  column_widths: { 1 => 73 })
    end
  end
end
