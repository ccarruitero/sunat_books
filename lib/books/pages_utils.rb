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

  def setup_pages(pages, length, page_max)
    page_num = (length / page_max.to_f).ceil
    (1..page_num).each do |i|
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
end
