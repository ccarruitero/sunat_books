require 'books/base'
require 'books/count_sum'

module Books
  class SimplifiedDiary < Base
    def initialize company, tickets, view, month, year
      super(page_layout: :landscape, margin: [5], page_size: "A4")
      @view = view
      @company = company
      @period = get_period(month, year)
      @tickets = tickets
      #@book_name = self.class.name.downcase.sub("books::", "")
      #dir = File.dirname(__FILE__)
      #@blayout = YAML.load_file("#{dir}/layouts/#{@book_name}.yml")
      repeat(:all) do
        canvas do
          bounding_box([bounds.left + 10, bounds.top - 10], width: 800) do
            book_title "LIBRO DIARIO - FORMATO SIMPLIFICADO"
            book_header @period, @company.ruc, @company.name
          end
        end
      end

      bounding_box([bounds.left + 3, bounds.top - 45], width: 790, height: 510) do
        book_body month, year
      end
    end

    def book_body month, year
      data = []
      # header
      counts = get_counts @tickets
      data << ['FECHA', 'OPERACIÓN', counts].flatten

      # body

      # initial entry
      initial = @tickets.where(operation_type: 'inicial')
      initial_row = get_row_sums(initial, counts)
      data << [Date.new(year.to_i, month.to_i, 1).to_s, 'ASIENTO INICIAL DEL PERIODO', initial_row].flatten

      # sales entry
      sales = @tickets.where(operation_type: 'ventas')
      sales_row = get_row_sums(sales, counts)
      data << [Date.new(year.to_i, month.to_i + 1, 1).prev_day.to_s, 'VENTAS DEL PERIODO', sales_row].flatten

      # buys entry
      buys = @tickets.where(operation_type: 'compras')
      buys_row = get_row_sums(buys, counts)
      data << [Date.new(year.to_i, month.to_i + 1, 1).prev_day.to_s, 'COMPRAS DEL PERIODO', buys_row].flatten

      # other entries
      others = @tickets.where(operation_type: 'otros')
      others.each do |ticket|
        ticket_data = []
        counts.each do |count|
          if uniq_counts(ticket).include? count
            value = ticket.get_amount count
          else
            value = zero
          end
          ticket_data << { content: formated_number(value), align: :right }
        end
        data << [ticket.operation.date, ticket.reference, ticket_data].flatten
      end

      # totals

      table(data, header: true, cell_style: {borders: [], size: 5})
    end
  end
end
