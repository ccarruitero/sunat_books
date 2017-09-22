# frozen_string_literal: true

require_relative "base"

module Books
  class TradingBook < Base
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
    end

    def prawn_book(title, page_max)
      prawn_header title, @period, @company
      @pages = []
      @page_max = page_max

      bounding_box([bounds.left + 3, bounds.top - 45], width: 800,
                                                       height: 530) do
        setup_pages(@pages, @tickets.length, @page_max)
        move_down 5
        book_body
      end
    end

    def book_body
      data = []
      fields = @blayout["headers"]
      data << table_head(fields, @book_name, @blayout)

      if @tickets.length.positive?
        row_data(data, @blayout["widths"], @blayout["align"], fields,
                 @book_name)
      else
        not_moviment_page(data)
      end
      render_prawn_table(data)
    end
  end
end
