# frozen_string_literal: true

require_relative "page"

module PagesUtils
  def page_not_full(last_page, pages, page_max, &block)
    if last_page.length < page_max
      last_page.length += 1
      last_page
    else
      yield if block
      setup_new_page(pages, last_page, 2)
    end
  end

  def setup_pages(pages, length, page_max, index = 1)
    pages_num = (length / page_max.to_f).ceil
    last_index = index.zero? ? pages_num - 1 : pages_num
    (index..last_index).each do |i|
      pages[i] = SunatBooks::Pdf::Page.new(i, 0)
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

  def page_index(index, page_max)
    index.zero? ? 1 : (index / page_max.to_f).ceil
  end

  def not_moviment_page(data)
    data << [{ content: "SIN MOVIMIENTO EN EL PERIODO", colspan: 5 }]
  end

  def setup_final_row_data(page, ticket, data)
    if page.length == @page_max && @tickets.last != ticket
      data << final_row("VAN", page)
    elsif @tickets.last == ticket
      data << final_row("TOTAL", page)
    end
  end

  def row_data(data, widths, aligns, fields, operation)
    @tickets.each_with_index do |ticket, i|
      last_page = @pages[page_index(i, @page_max)]
      page = page_not_full(last_page, @pages, @page_max) do
        data << final_row("VIENEN", last_page)
      end
      data << table_body(fields, ticket, widths, aligns)
      page.send("update_data_#{operation}", ticket)
      setup_final_row_data(page, ticket, data)
    end
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
