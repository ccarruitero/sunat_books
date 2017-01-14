require "cutest"
require "pry"
require_relative "../lib/sunat_books"
require_relative "fixtures/ticket"

def get_line array, object
  str = ""
  array.each {|f| str += object.send("#{f}") + "|"}
  str
end

def random_string array
  array.slice(SecureRandom.random_number(array.count - 1))
end
