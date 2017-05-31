# frozen_string_literal: true

require_relative "base"
require_relative "page"

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
      @book_name = self.class.name.downcase.sub("books::", "")
      dir = File.dirname(__FILE__)
      @blayout = YAML.load_file("#{dir}/layouts/#{@book_name}.yml")
      @page_max = 27

      prawn_book
    end

    def prawn_book
      prawn_header "REGISTRO DE COMPRAS", @period, @company

      bounding_box([bounds.left + 3, bounds.top - 45], width: 800,
                                                       height: 530) do
        setup_pages
        book_body
      end
    end

    def final_row(foot_line_text, page)
      [{ content: foot_line_text, colspan: 5 },
       make_sub_table([page.bi_sum, page.igv_sum], 32),
       make_sub_table([zero, zero], 25),
       make_sub_table([zero, zero], 25),
       formated_number(page.non_taxable),
       zero, zero,
       formated_number(page.total_sum)]
    end

    def setup_pages
      @pages = []
      page_num = (@tickets.length / 27.0).ceil
      page_num.times do |i|
        n_number = i + 1
        @pages[n_number] = Books::Page.new(n_number, 0)
        # @pages[i + 1] = Books::Page.new(i)
      end
    end

    def book_body
      move_down 5
      data = []
      fields = @blayout["headers"]
      data << table_head(fields, @book_name, @blayout)
      if @tickets.length.positive?
        row_data(data, @blayout["widths"], @blayout["align"], fields)
      else
        not_moviment_page(data)
      end
      render_prawn_table(data)
    end

    def not_moviment_page(data)
      data << [content: "SIN MOVIMIENTO EN EL PERIODO", colspan: 5]
    end

    def render_prawn_table(data)
      table(data, header: true, cell_style: { borders: [], size: 5,
                                              align: :right },
                  column_widths: { 0 => 22, 1 => 35, 2 => 30, 8 => 30,
                                   10 => 30, 9 => 22, 11 => 33, 12 => 33 }) do
        row(0).borders = %i[bottom top]
      end
    end

    def unblocked_page(data, i)
      last_page = @pages[i / (@page_max + 1) + 1]
      if last_page.length < @page_max
        last_page.length += 1
        last_page
      else
        data << final_row("VIENEN", last_page)
        new_page = @pages[last_page.page_number + 1]
        new_page.length += 2
        new_page
      end
    end

    def setup_final_row_data(page, ticket, data)
      if page.length == @page_max && @tickets.last != ticket
        data << final_row("VAN", page)
      elsif @tickets.last == ticket
        data << final_row("TOTAL", page)
      end
    end

    def row_data(data, widths, aligns, fields)
      @tickets.each_with_index do |ticket, i|
        page = unblocked_page(data, i)
        data << table_body(fields, ticket, widths, aligns)
        page.update_data(ticket)
        setup_final_row_data(page, ticket, data)
      end
    end
  end
end
