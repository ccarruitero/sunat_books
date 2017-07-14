# frozen_string_literal: true

require_relative "pages_utils"

module DiaryCalculations
  include PagesUtils

  def split_data(data, max_column)
    # split rows data in pages according max_column
    pages = []
    setup_pages(pages, data.first.count, max_column, 0)
    data&.each do |row|
      if row == data.last
        setup_row_pages(pages, row, max_column - 1, 1)
      else
        setup_row_pages(pages, row, max_column)
      end
    end
    pages
  end

  def setup_row_pages(pages, row, max_column, first_rows = 2)
    initial_rows = row.first(first_rows)
    batches_length = max_column - first_rows
    left_data = row[first_rows..row.length].in_groups_of(batches_length, false)
    pages.each_with_index do |page, i|
      page.data << (initial_rows + left_data[i])
    end
  end
end
