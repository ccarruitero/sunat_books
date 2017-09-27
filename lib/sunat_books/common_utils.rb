# frozen_string_literal: true

module SunatBooks
  module CommonUtils
    def available_value?(source, attribute)
      source.respond_to?(attribute) ? source.send(attribute) : ""
    end
  end
end
