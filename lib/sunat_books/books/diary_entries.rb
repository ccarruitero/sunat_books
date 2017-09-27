# frozen_string_literal: true

module DiaryEntries
  def initial_entry(tickets, counts, total_sums)
    initial = tickets.where(operation_type: "inicial")
    if !initial.empty?
      initial_data = get_row_sums(initial, counts, total_sums)
    else
      initial_data = []
      total_sums.map do |sum|
        initial_data << { content: formated_number(sum.total), align: :right }
      end
    end
    initial_data
  end

  def buys_entry(tickets, counts, total_sums, data, period_date)
    buys = tickets.where(operation_type: "compras")
    title = "COMPRAS DEL PERIODO"
    return unless buys.count.positive?
    buys_sum = get_row_sums(buys, counts, total_sums)
    data << [period_date, title, buys_sum].flatten
  end

  def sales_entry(tickets, counts, total_sums, data, period_date)
    sales = tickets.where(operation_type: "ventas")
    title = "VENTAS DEL PERIODO"
    return unless sales.count.positive?
    sales_sum = get_row_sums(sales, counts, total_sums)
    data << [period_date, title, sales_sum].flatten
  end

  def other_entry(tickets, counts, total_sums, data)
    others = tickets.where(operation_type: "otros")
    # others_row = get_row_sums(others, counts, total_sums)
    others&.each do |ticket|
      ticket_data = []
      counts.each_with_index do |count, i|
        value = mother_count?(count, ticket) ? get_value(ticket, count) : 0
        increase_value(ticket_data, total_sums, i, value)
      end
      ref = ticket.reference
      data << [parse_day(ticket.operation_date), ref, ticket_data].flatten
    end
  end

  def close_entry(tickets, counts, total_sums, data)
    close = tickets.where(operation_type: "cierre")
    close.each do |ticket|
      ticket_data = []
      counts.each_with_index do |count, i|
        value = mother_count?(count, ticket) ? get_value(ticket, count) : 0
        increase_value(ticket_data, total_sums, i, value)
      end
      ref = ticket.reference
      data << [parse_day(ticket.operation_date), ref, ticket_data].flatten
    end
  end

  def total_entry(total_sums, data)
    # totals
    total_data = []
    total_sums.map do |sum|
      total_data << { content: formated_number(sum.total), align: :right }
    end
    data << [{ content: "TOTALES", colspan: 2 }, total_data].flatten
  end

  def mother_count?(count, ticket)
    ticket.uniq_mother_counts.include?(count)
  end

  def calculate_totals(tickets, count_sums)
    # get totals
    tickets.each do |ticket|
      count_sums.each do |count_sum|
        count_sum.add get_value(ticket, count_sum.count)
      end
    end
  end

  def current_sum_count(count_sums, count)
    sum_count = nil
    count_sums.each do |count_sum|
      sum_count = count_sum if count_sum.count == count
    end
    sum_count
  end

  def get_row_sums(tickets, counts, total_sums)
    # given an array of counts and tickets get sums by each count
    row_counts = get_mother_counts tickets
    count_sums = row_counts.map { |count| Books::CountSum.new(count) }

    calculate_totals(tickets, count_sums)
    # get ordered row
    row_data = []
    counts.each_with_index do |count, i|
      sum_count = current_sum_count(count_sums, count)
      value = sum_count ? sum_count.total : 0
      increase_value(row_data, total_sums, i, value)
    end
    row_data
  end

  def increase_value(row_data, total_sums, i, value)
    total_sums[i].add value
    row_data << { content: formated_number(value), align: :right }
  end
end
