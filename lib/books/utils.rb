# frozen_string_literal: true

require "active_support/all"
require_relative "count_sum"

module Utils
  include ActiveSupport::NumberHelper

  def formated_number(float)
    number_to_currency(float, unit: "")
  end

  def get_date(year, month, day)
    parse_day(Date.new(year.to_i, month.to_i, day))
  end

  def parse_day(day)
    day.strftime("%d-%m").to_s
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
