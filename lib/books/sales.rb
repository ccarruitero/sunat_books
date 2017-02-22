# frozen_string_literal: true
require "books/base"

module Books
  class Sales < Base
    def initialize(company, tickets, view, month, year)
      super(page_layout: :landscape, margin: [5], page_size: "A4")
      @view = view
      @company = company
      @period = get_period(month, year)
      @tickets = tickets
      @book_name = self.class.name.downcase.sub("books::", "")
      dir = File.dirname(__FILE__)
      @blayout = YAML.load_file("#{dir}/layouts/#{@book_name}.yml")
      @page_max = 29

      prawn_book
    end

    def prawn_header(title)
      repeat(:all) do
        canvas do
          bounding_box([bounds.left + 10, bounds.top - 10], width: 800) do
            book_header @period, @company.ruc, @company.name, title
          end
        end
      end
    end

    def prawn_book
      prawn_header "REGISTRO DE VENTAS"

      bounding_box([bounds.left + 3, bounds.top - 45], width: 800,
                                                       height: 530) do
        book_body
      end

      # repeat(:all, dynamic: true) do
      #   canvas do
      #     bounding_box([235, 50], width: 700) do
      #       book_footer
      #     end
      #   end
      # end
    end

    def instantiate_pages
      @pages = {}
      length = @tickets.length
      page_num = (length / 29.0).ceil
      page_num.times do |i|
        @pages[i + 1] = {
          page_number: i + 1,
          length: 0,
          bi_sum: BigDecimal(0)
        }
      end
    end

    def book_body
      instantiate_pages
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

      if length.positive?
        @tickets.each do |ticket|
          if @pages[n][:length] < @page_max
            page = @pages[n]
            page[:length] += 1
          else
            data << final_row("VIENEN", @pages[n])
            page = @pages[n + 1]
            n += 1
            page[:length] += 2
          end

          data << table_body(fields, ticket, widths, aligns)

          bi_sum += ticket.taxable_bi
          igv_sum += ticket.igv
          total_sum += ticket.total_operation_sales
          page[:bi_sum] = bi_sum.round(2)
          page[:igv_sum] = igv_sum.round(2)
          page[:total_sum] = total_sum.round(2)
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
      end

      render_prawn_table(data)
    end

    def render_prawn_table(data)
      widths_columns = { 0 => 22, 1 => 35, 2 => 30, 5 => 27, 6 => 37, 8 => 20,
                         9 => 33, 10 => 27, 11 => 35, 12 => 29 }

      table(data, header: true,
                  cell_style: { borders: [], size: 5, align: :right },
                  column_widths: widths_columns) do
        row(0).borders = [:bottom, :top]
      end
    end

    def final_row(foot_line_text, page)
      [{ content: foot_line_text, colspan: 5 }, zero,
       formated_number(page[:bi_sum]), make_sub_table([zero, zero], 22), zero,
       formated_number(page[:igv_sum]), zero,
       formated_number(page[:total_sum])]
    end
  end
end
