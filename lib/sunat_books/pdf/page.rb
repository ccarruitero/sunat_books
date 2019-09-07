# frozen_string_literal: true

require_relative "base"

module SunatBooks
  module Pdf
    class Page < Base
      attr_accessor :length, :bi_sum, :igv_sum, :total_sum, :non_taxable, :data

      def initialize(page_number, length)
        @page_number = page_number
        @length = length
        @bi_sum = BigDecimal(0)
        @igv_sum = BigDecimal(0)
        @total_sum = BigDecimal(0)
        @non_taxable = BigDecimal(0)
        @data = []
      end

      def update_data_buys(ticket)
        @bi_sum += ticket.taxable_to_taxable_export_bi.round(2)
        @igv_sum += ticket.taxable_to_taxable_export_igv.round(2)
        @total_sum += ticket.total_operation_buys.round(2)
        @non_taxable += ticket.non_taxable unless ticket.non_taxable.nil?
      end

      def update_data_sales(ticket)
        @bi_sum += ticket.taxable_bi.round(2)
        @igv_sum += ticket.igv.round(2)
        @total_sum += ticket.total_operation_sales.round(2)
      end

      def update_fields(fields = nil, source = nil)
        # update fields from a given source
        return if source.nil?

        fields&.each do |field|
          send("#{field}=", source.send(field)) if available?(field, source)
        end
      end

      private

      def available?(field, source)
        respond_to?("#{field}=") && source.respond_to?(field)
      end
    end
  end
end
