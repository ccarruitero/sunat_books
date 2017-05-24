# frozen_string_literal: true

require_relative "base"

module Books
  class Page < Base
    attr_accessor :length, :bi_sum, :igv_sum, :total_sum, :non_taxable

    def initialize(page_number, length)
      @page_number = page_number
      @length = length
      @bi_sum = BigDecimal(0)
      @igv_sum = BigDecimal(0)
      @total_sum = BigDecimal(0)
      @non_taxable = BigDecimal(0)
    end

    # def update_field()
    # end
  end
end
