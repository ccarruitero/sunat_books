# frozen_string_literal: true

require_relative "base"
require_relative "pages_utils"

module Books
  class Buys < Base
    include PagesUtils

    def initialize(company, tickets, month, year)
      # company => an object that respond to ruc and name methods
      # tickets => an array of objects that respond to a layout's methods
      # month => a number that represent a month
      # year => a number that represent a year
      super(page_layout: :landscape, margin: [5], page_size: "A4")
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
      @pages = []

      bounding_box([bounds.left + 3, bounds.top - 45], width: 800,
                                                       height: 530) do
        setup_pages(@pages, @tickets.length, @page_max)
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

    def book_body
      move_down 5
      data = []
      fields = @blayout["headers"]
      data << table_head(fields, @book_name, @blayout)
      if @tickets.length.positive?
        row_data(data, @blayout["widths"], @blayout["align"], fields, "buys")
      else
        not_moviment_page(data)
      end
      render_prawn_table(data)
    end

    def render_prawn_table(data)
      table(data, header: true, cell_style: { borders: [], size: 5,
                                              align: :right },
                  column_widths: { 0 => 22, 1 => 35, 2 => 30, 8 => 30,
                                   10 => 30, 9 => 22, 11 => 33, 12 => 33 }) do
        row(0).borders = %i[bottom top]
      end
    end
  end
end
