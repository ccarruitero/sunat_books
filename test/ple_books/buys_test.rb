# frozen_string_literal: true
require_relative "helper"

setup do
  tickets = [{}]
  ruc = "102392839213"
  @ple_buys = PleBooks::Buys.new(ruc, tickets, 10, 2013)
end

test "generate txt file" do
  assert File.exist?(@ple_buys.file)
end

test "tickets empty" do
  ple_buys = PleBooks::Buys.new("10293827481", {}, 10, 2011)
  assert File.exist?(ple_buys.file)
end

scope "custom layout" do
  test "allow custom file for layout" do
    dir = File.dirname(__FILE__)
    yml = "#{dir}/fixtures/custom_layout.yml"
    tickets = []
    field_value = SecureRandom.hex(10)
    tickets << Ticket.new(custom_field: field_value)
    ple_buys = PleBooks::Buys.new("10293827481", tickets, 10, 2011,
                                  yml: yml)
    file = ple_buys.file
    assert File.exist?(file)

    txt = File.read(file)
    assert txt.include?(field_value)
  end

  test "allow change individual field" do
    tickets = []
    tickets << Ticket.new(period: "20151000", operation_day: "20/10/2015")
    ple_buys = PleBooks::Buys.new("10293827481", tickets, 10, 2015,
                                  layout: {
                                    operation_date: "operation_day"
                                  })
    file = ple_buys.file
    assert File.exist?(file)

    txt = File.read(file)
    assert txt.include?("20/10/2015")
  end
end
