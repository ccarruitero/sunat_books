# frozen_string_literal: true

require_relative "page"

module PagesUtils
  def page_not_full(last_page, pages, page_max, &block)
    if last_page.length < page_max
      last_page.length += 1
      last_page
    else
      yield if block
      new_page = setup_new_page(pages, last_page, 2)
      new_page
    end
  end

  def setup_pages(pages, length, page_max, index = 1)
    pages_num = (length / page_max.to_f).ceil
    last_index = index.zero? ? pages_num - 1 : pages_num
    (index..last_index).each do |i|
      pages[i] = Books::Page.new(i, 0)
    end
  end

  def setup_new_page(pages, last_page, length)
    return if last_page.page_number == pages.count
    new_page = pages[last_page.page_number + 1]
    fields = %w[bi_sum igv_sum total_sum non_taxable]
    new_page.update_fields(fields, last_page)
    new_page.length += length
    new_page
  end

  def page_index(i, page_max)
    i.zero? ? 1 : (i / page_max.to_f).ceil
  end

  # for diary
  def split_data(data, max_column)
    # split rows data in pages according max_column
    pages = []
    setup_pages(pages, data.first.count, max_column, 0)
    data&.each_with_index do |row, i|
      if i == data.length - 1
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
