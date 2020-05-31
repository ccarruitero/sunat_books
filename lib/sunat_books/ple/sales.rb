# frozen_string_literal: true

require "sunat_books/ple/base"

module SunatBooks
  module Ple
    class Sales < Base
      def initialize(ruc, tickets, month, year, options = {})
        options[:book_format] = options[:book_format] || "14.2"
        super(ruc, tickets, month, year, options)
      end
    end
  end
end
