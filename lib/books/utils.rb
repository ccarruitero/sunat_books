# frozen_string_literal: true
require "active_support/all"
require "books/count_sum"

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

  # calculations? row calculations?
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
    row_data = []
    counts.each_with_index do |count, i|
      sum_count = nil
      count_sums.each do |count_sum|
        sum_count = count_sum if count_sum.count == count
      end

      value = sum_count ? sum_count.total : 0
      total_sums[i].add value
      row_data << { content: formated_number(value), align: :right }
    end
    row_data
  end
end
