# frozen_string_literal: true

require "prawn"
require "prawn/table"
require "yaml"
require_relative "utils"
require_relative "locale"

module SunatBooks
  module Pdf
    class Base < Prawn::Document
      include Utils
      include Prawn::Table::Interface

      def sub_head(hash, book_name, blayout)
        arr, current_key = nil
        hash.each do |key, value|
          k = I18n.t("books.#{book_name}.#{key}").mb_chars.upcase.to_s
          v = value.collect do |s|
            I18n.t("books.#{book_name}.#{s}").mb_chars.upcase.to_s
          end
          arr = [[{ content: k, colspan: value.length }], v]
          current_key = key
        end

        sub_head_table(blayout["widths"], arr, current_key)
      end

      def sub_head_table(widths, arr, key)
        column_widths = get_column_widths(widths, key)
        options = sub_head_options(column_widths)
        make_table(arr, options)
      end

      def sub_head_options(column_widths)
        options = { cell_style: {
          borders: [], size: 5, align: :center, padding: 1
        } }
        add_widths(column_widths, options, 22)
        options
      end

      def book_title(title)
        text title, align: :center, size: 8
      end

      def book_header(period, ruc, name, title = nil)
        move_down 5
        txt name.to_s.upcase
        txt "RUC: #{ruc}"
        book_title("#{title} - #{period}")
        move_down 5
      end

      def prawn_header(title, period, company)
        repeat(:all) do
          canvas do
            bounding_box([bounds.left + 10, bounds.top - 10], width: 800) do
              book_header period, company.ruc, company.name, title
            end
          end
        end
      end

      def table_head(fields, book_name, layout)
        thead = []
        fields.each do |h|
          if h.class == Hash
            r = sub_head(h, book_name, layout)
            thead << r
          else
            thead << I18n.t("books.#{book_name}.#{h}").mb_chars.upcase.to_s
          end
        end
        thead
      end

      def table_body(fields, ticket, widths, aligns)
        tbody = []
        fields.each do |f|
          if f.is_a? Hash
            table_hash(f, ticket, tbody, widths, aligns)
          else
            tbody << field_value(ticket, f)
          end
        end
        tbody
      end

      def table_hash(field, ticket, tbody, widths, aligns)
        options = { cell_style: { borders: [], size: 5 } }

        field.each do |key, value|
          v = value.collect do |s|
            value = field_value(ticket, s)
          end

          column_widths = get_column_widths(widths, key)
          add_widths(column_widths, options, 28)
          add_align(aligns, options, key) unless aligns.nil?
          tbody << make_table([v], options)
        end
      end

      # diary
      def get_counts(tickets)
        tickets.map(&:uniq_counts).flatten.uniq.sort
      end

      def get_mother_counts(tickets)
        tickets.map(&:uniq_mother_counts).flatten.uniq.sort
      end

      def get_value(ticket, count)
        # active_amount = ticket.get_amount_by_position(count)
        # pasive_amount = ticket.get_amount_by_position(count, false)
        active_amount = ticket.get_amount_by_mother_count(count)
        pasive_amount = ticket.get_amount_by_mother_count(count, false)
        # if count === '401' && ticket.operation_type == 'compras'
        #   amount = amount * (-1)
        # end
        active_amount - pasive_amount
      end

      def make_sub_table(content, width = nil)
        options = { cell_style: { width: width, size: 5, borders: [],
                                  align: :right } }
        content_row = []
        content.each { |c| content_row << formated_number(c) }
        make_table([content_row], options)
      end
    end
  end
end
