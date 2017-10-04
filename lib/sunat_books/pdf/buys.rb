# frozen_string_literal: true

require_relative "trading_book"
require_relative "pages_utils"

module SunatBooks
  module Pdf
    class Buys < TradingBook
      include PagesUtils

      def initialize(company, tickets, month, year)
        super
        prawn_book("REGISTRO DE COMPRAS", 27)
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
end
