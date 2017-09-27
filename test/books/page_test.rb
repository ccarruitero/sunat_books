# frozen_string_literal: true

require_relative "../helper"
require "sunat_books/books/page"

setup do
  @page = Books::Page.new(1, 1)
end

test "#update_data" do
end

test "#update_fields should return nil if not source is provided" do
  assert_equal @page.update_fields([]), nil
end

test "#update_fields should handle if undefined method" do
  other_page = Books::Page.new(2, 1)
  @page.update_fields([:foo], other_page)

  other_page.bi_sum += BigDecimal(10)
  @page.update_fields([:bi_sum], other_page)
  assert_equal @page.bi_sum, other_page.bi_sum
end
