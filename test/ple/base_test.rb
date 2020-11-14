# frozen_string_literal: true

require_relative "../helper"

setup do
  @tickets = [{}]
  @ruc = "102392839213"
end

test "raise error when layout file doesnt exist" do
  assert_raise SunatBooks::Errors::InvalidLayoutError do
    SunatBooks::Ple::Base.new(@ruc, @tickets, 10, 2013, { yml: "not-file" })
  end
end
