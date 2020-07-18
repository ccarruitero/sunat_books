# frozen_string_literal: true

require "sunat_books/ple/base"

module SunatBooks
  module Ple
    class Buys < Base
      def initialize(ruc, tickets, month, year, options = {})
        options[:book_format] = options[:book_format] || "8.1"
        super(ruc, tickets, month, year, options)
      end
    end
  end
end
