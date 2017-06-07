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

    def update_data(ticket)
      @bi_sum += ticket.taxable_to_taxable_export_bi.round(2)
      @igv_sum += ticket.taxable_to_taxable_export_igv.round(2)
      @total_sum += ticket.total_operation_buys.round(2)
      @non_taxable += ticket.non_taxable unless ticket.non_taxable.nil?
    end

    def update_fields(fields = nil, source = nil)
      # update fields from a given source
      return if source.nil?
      fields&.each do |field|
        begin
          send("#{field}=", source.send(field))
        rescue
          return nil
        end
      end
    end
  end
end
