# frozen_string_literal: true

require_relative "trading_book"
require_relative "pages_utils"

module SunatBooks
  module Pdf
    class Sales < TradingBook
      include PagesUtils

      def initialize(company, tickets, month, year)
        super
        prawn_book("REGISTRO DE VENTAS", 29)
      end

      def render_prawn_table(data)
        widths_columns = { 0 => 22, 1 => 35, 2 => 30, 5 => 27, 6 => 37, 8 => 20,
                           9 => 33, 10 => 27, 11 => 35, 12 => 29 }

        table(data, header: true,
                    cell_style: { borders: [], size: 5, align: :right },
                    column_widths: widths_columns) do
          row(0).borders = %i[bottom top]
        end
      end

      def final_row(foot_line_text, page)
        [{ content: foot_line_text, colspan: 5 }, zero,
         formated_number(page.bi_sum), make_sub_table([zero, zero], 22), zero,
         formated_number(page.igv_sum), zero,
         formated_number(page.total_sum)]
      end
    end
  end
end
