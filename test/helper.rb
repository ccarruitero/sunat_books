# frozen_string_literal: true

require "cutest"
require "pry"
require "faker"
require_relative "../lib/sunat_books"
require_relative "fixtures/ticket"
require_relative "fixtures/company"

Prawn.debug = true

require "pdf/inspector"

def get_line(array, object)
  str = ""
  array.each { |f| str += "#{object.send(f.to_s)}|" }
  str
end

def random_string(array)
  array.slice(SecureRandom.random_number(array.count - 1))
end
