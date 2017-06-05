# frozen_string_literal: true

module DiaryCalculations
  def setup_column(pages, n)
    pages["tmp#{n}"] = []
  end

  def split_data(data, max_column)
    # split rows data in pages according max_column variable
    respond = {}
    pages_number = (data.first.count / max_column.to_f).ceil - 1
    (0..pages_number).each { |n| setup_column(respond, n) }
    data.each do |column|
      if column == data.last
        page_range = max_column - 1
        first_page = column.first(page_range)
        second_page = column[(page_range)..column.length]
        respond["tmp0"] << first_page
        next_page = [column.first]
        (next_page += second_page) unless second_page.nil?
        respond["tmp1"] << next_page
      elsif column.length < max_column
        respond["tmp0"] << column
      else
        first_page = column.first(max_column)
        respond["tmp0"] << first_page

        # TODO: make the same for more than 2 pages
        next_page = column.first(2) + (column[max_column..column.length])
        respond["tmp1"] << next_page
      end
    end
    respond
  end
end
