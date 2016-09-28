require 'books/base'

module Books
  class Buys < Base
    attr_accessor :pages

    def initialize(company, tickets, view, month, year)
      super(page_layout: :landscape, margin: [5], page_size: "A4")
      @view = view
      @company = company
      @period = get_period(month, year)
      @tickets = tickets
      @pages = {}
      @book_name = self.class.name.downcase.sub("books::", "")
      dir = File.dirname(__FILE__)
      @blayout = YAML.load_file("#{dir}/layouts/#{@book_name}.yml")
      repeat(:all) do
        canvas do
          bounding_box([bounds.left + 10, bounds.top - 10], width: 800) do
            book_title "REGISTRO DE COMPRAS"
            book_header @period, @company.ruc, @company.name
          end
        end
      end

      bounding_box([bounds.left + 3, bounds.top - 45], width: 800, height: 510) do
        book_body
      end

      repeat(:all, dynamic: true) do
        canvas do
          bounding_box([280, 50], width: 800) do
            book_footer
          end
        end
      end
    end

    def book_footer
      arr = []
      if page_count == page_number
        letter = "TOTAL"
      else
        letter = "VAN"
      end

      bi_sum= formated_number(@pages[page_number][:bi_sum].to_f)
      igv_sum= formated_number(@pages[page_number][:igv_sum].to_f)
      total_sum= formated_number(@pages[page_number][:total_sum].to_f)
      non_taxable= formated_number(@pages[page_number][:non_taxable].to_f)

      if @pages[page_number - 1] != nil
        letter1 = "VIENEN"
        p = @pages[page_number - 1]
        bi_sum1 = formated_number(p[:bi_sum].to_f)
        igv_sum1 = formated_number(p[:igv_sum].to_f)
        total_sum1 = formated_number(p[:total_sum].to_f)
        non_taxable1= formated_number(p[:non_taxable].to_f)
        arr << [letter1, bi_sum1, igv_sum1, zero, zero, zero, zero, non_taxable1, zero, zero, total_sum1]
      end
      arr << [letter, bi_sum, igv_sum, zero, zero, zero, zero, non_taxable, zero, zero, total_sum]
      table( arr, cell_style: {align: :right, borders: [], size: 5}, column_widths: [33, 35, 30, 25,25,25,25, 22, 30 ,25, 35])
    end

    def book_body
      # get total number of tickets
      length = @tickets.length
      page_num = (length / 25.0).ceil
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
          data << table_body(fields, ticket, widths, aligns)

          if @pages[n][:length] < 25
            page = @pages[n]
            page[:length] += 1
          else
            page = @pages[n + 1]
            n += 1
            page[:length] += 1
          end

          bi_sum += ticket.taxable_to_taxable_export_bi
          igv_sum += ticket.taxable_to_taxable_export_igv
          total_sum += ticket.total_operation_buys
          non_taxable += ticket.non_taxable unless ticket.non_taxable.nil?
          page[:bi_sum] = bi_sum.round(2)
          page[:igv_sum] = igv_sum.round(2)
          page[:total_sum] = total_sum.round(2)
          page[:non_taxable] = non_taxable.round(2)
        end
      else
        data << [content: 'SIN MOVIMIENTO EN EL PERIODO', colspan: 5]
        @pages[n] = {}
        page = @pages[n]
        page[:bi_sum] = zero
        page[:igv_sum] = zero
        page[:total_sum] = zero
        page[:non_taxable] = zero
      end

      table(data, header: true, cell_style: {borders: [], size: 5, align: :right},
            column_widths: {0 => 22, 1 => 35, 2 => 30, 8 => 30, 10 => 30,
                            9 => 22, 11 => 33, 12 => 33})
    end
  end
end
