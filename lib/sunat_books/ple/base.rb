# frozen_string_literal: false

require "csv"
require_relative "../common_utils"
require_relative "./utils"

module SunatBooks
  module Ple
    class Base
      include SunatBooks::CommonUtils
      include Utils

      attr_accessor :file
      attr_reader :book_format
    end
  end
end
