# frozen_string_literal: true

require "active_support/all"
require_relative "count_sum"
require_relative "../common_utils"

module Utils
  include ActiveSupport::NumberHelper
  include SunatBooks::CommonUtils

  MONTHS = { 1 => "Enero", 2 => "Febrero", 3 => "marzo", 4 => "abril",
             5 => "mayo", 6 => "junio", 7 => "julio", 8 => "agosto",
             9 => "setiembre", 10 => "octubre", 11 => "noviembre",
             12 => "diciembre" }.freeze

  def formated_number(float)
    number_to_currency(float, unit: "")
  end

  def get_date(year, month, day)
    parse_day(Date.new(year.to_i, month.to_i, day))
  end

  def get_period(month, year)
    "#{MONTHS[month.to_i].upcase} #{year}"
  end

  def parse_day(day)
    day.strftime("%d-%m").to_s
  end

  def add_align(aligns, options, key)
    cell_style = options[:cell_style]
    aligns.map do |a|
      cell_style.merge!(align: a[key][0].to_sym) unless a[key].nil?
    end
  end

  def add_widths(column_widths, options, width)
    if column_widths.empty?
      options[:cell_style][:width] = width
    else
      options.merge!(column_widths: column_widths)
    end
  end

  def get_column_widths(widths, key)
    obj = {}
    widths&.each do |w|
      obj = w[key].flatten unless w[key].nil?
    end
    obj
  end

  def txt(txt)
    text txt, size: 8
  end

  def zero
    formated_number(0)
  end

  def field_value(ticket, field)
    value = available_value?(ticket, field)
    value = formated_number(value) if value.class == BigDecimal
    value
  end

  def sum_count(count_sums, count)
    sum = nil
    count_sums.each do |count_sum|
      sum = count_sum if count_sum.count == count
    end
    sum
  end

  def order_data_row(counts, count_sums, total_sums)
    data = []
    counts.each_with_index do |count, i|
      sum = sum_count(count_sums, count)
      value = sum ? sum.total : 0
      total_sums[i].add value
      data << { content: formated_number(value), align: :right }
    end
    data
  end

  def get_row_sums(tickets, counts, total_sums)
    # given an array of counts and tickets get sums by each count
    row_counts = get_mother_counts tickets
    count_sums = row_counts.map { |count| Books::CountSum.new(count) }

    # get totals
    tickets.each do |ticket|
      count_sums.each do |count_sum|
        count_sum.add get_value(ticket, count_sum.count)
      end
    end

    # get ordered row
    order_data_row(counts, count_sums, total_sums)
  end
end
