require "books/base"

module Books
  class Buys < Base
    attr_accessor :pages

    def initialize(company, tickets, view, month, year)
      # company => an object that respond to ruc and name methods
      # tickets => an array of objects that respond to a layout's methods
      # view => a view context
      # month => a number that represent a month
      # year => a number that represent a year
      super(page_layout: :landscape, margin: [5], page_size: "A4")
      @view = view
      @company = company
      @period = get_period(month, year)
      @tickets = tickets
      @pages = {}
      @book_name = self.class.name.downcase.sub("books::", "")
      dir = File.dirname(__FILE__)
      @blayout = YAML.load_file("#{dir}/layouts/#{@book_name}.yml")
      @page_max = 27

      repeat(:all) do
        canvas do
          bounding_box([bounds.left + 10, bounds.top - 10], width: 800) do
            book_header @period, @company.ruc, @company.name, "REGISTRO DE COMPRAS"
          end
        end
      end

      bounding_box([bounds.left + 3, bounds.top - 45], width: 800, height: 530) do
        book_body
      end
    end

    def final_row(foot_line_text, page)
      [{ content: foot_line_text, colspan: 5 },
       make_sub_table([page[:bi_sum], page[:igv_sum]], 32),
       make_sub_table([zero, zero], 25),
       make_sub_table([zero, zero], 25),
       formated_number(page[:non_taxable]),
       zero, zero,
       formated_number(page[:total_sum])]
    end

    def book_body
      # get total number of tickets
      length = @tickets.length
      page_num = (length / 27.0).ceil
      page_num.times do |i|
        pages[i + 1] = {
          page_number: i + 1,
          length: 0,
          bi_sum: BigDecimal(0)
        }
      end

      move_down 5
      fields = @blayout["headers"]
      widths = @blayout["widths"]
      aligns = @blayout["align"]
      data = []
      data << table_head(fields, @book_name, @blayout)

      n = 1
      bi_sum = BigDecimal(0)
      igv_sum = BigDecimal(0)
      total_sum = BigDecimal(0)
      non_taxable = BigDecimal(0)

      if length > 0
        @tickets.each do |ticket|
          if @pages[n][:length] < @page_max
            page = @pages[n]
            page[:length] += 1
          else
            data << final_row("VIENEN", @pages[n])

            n += 1
            page = @pages[n]
            page[:length] += 2
          end

          data << table_body(fields, ticket, widths, aligns)

          bi_sum += ticket.taxable_to_taxable_export_bi
          igv_sum += ticket.taxable_to_taxable_export_igv
          total_sum += ticket.total_operation_buys
          non_taxable += ticket.non_taxable unless ticket.non_taxable.nil?
          page[:bi_sum] = bi_sum.round(2)
          page[:igv_sum] = igv_sum.round(2)
          page[:total_sum] = total_sum.round(2)
          page[:non_taxable] = non_taxable.round(2)
          if page[:length] == @page_max && @tickets.last != ticket
            data << final_row("VAN", page)
          elsif @tickets.last == ticket
            data << final_row("TOTAL", page)
          end
        end
      else
        data << [content: "SIN MOVIMIENTO EN EL PERIODO", colspan: 5]
        @pages[n] = {}
        page = @pages[n]
        page[:bi_sum] = zero
        page[:igv_sum] = zero
        page[:total_sum] = zero
        page[:non_taxable] = zero
      end

      table(data, header: true, cell_style: { borders: [], size: 5, align: :right },
            column_widths: { 0 => 22, 1 => 35, 2 => 30, 8 => 30, 10 => 30,
                             9 => 22, 11 => 33, 12 => 33 }) do
        row(0).borders = [:bottom, :top]
      end
    end
  end
end
