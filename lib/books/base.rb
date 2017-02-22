# frozen_string_literal: true
require "prawn"
require "yaml"
require_relative "utils"

module Books
  class Base < Prawn::Document
    MONTHS = { 1 => "Enero", 2 => "Febrero", 3 => "marzo", 4 => "abril",
               5 => "mayo", 6 => "junio", 7 => "julio", 8 => "agosto",
               9 => "setiembre", 10 => "octubre", 11 => "noviembre",
               12 => "diciembre" }.freeze

    def add_align(aligns, options, key)
      cell_style = options[:cell_style]
      aligns.map do |a|
        cell_style.merge!(align: a[key][0].to_sym) unless a[key].nil?
      end
    end

    def txt(txt)
      text txt, size: 8
    end

    def sub_head(hash, book_name, blayout)
      arr = nil
      current_key = nil
      column_widths = {}
      hash.each do |key, value|
        k = I18n.t("books.#{book_name}.#{key}").mb_chars.upcase.to_s
        v = value.collect do |s|
          I18n.t("books.#{book_name}.#{s}").mb_chars.upcase.to_s
        end
        arr = [[{ content: k, colspan: value.length }], v]
        current_key = key
      end

      widths = blayout["widths"]
      unless widths
        widths.each do |w|
          column_widths = w[current_key].flatten unless w[current_key].nil?
        end
      end
      if !column_widths.empty?
        make_table(arr, cell_style: { borders: [], size: 5, align: :center },
                        column_widths: column_widths) do
          cells.padding = 1
        end
      else
        make_table(arr, cell_style: { borders: [], size: 5, width: 22,
                                      padding: 1, align: :center })
      end
    end

    def get_period(month, year)
      "#{MONTHS[month.to_i].upcase} #{year}"
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

    def zero
      formated_number(0)
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
        if f.class == Hash
          f.each do |key, value|
            v = value.collect do |s|
              begin
                value = ticket.send(s)
                value = formated_number(value) if value.class == BigDecimal
              rescue
                value = ""
              end
              value
            end
            options = { cell_style: { borders: [], size: 5 } }
            column_widths = nil
            # unless widths.nil?
            widths.each do |w|
              column_widths = w[key].flatten unless w[key].nil?
            end
            # end
            if !column_widths.nil?
              options = options.merge(column_widths: column_widths)
            else
              options[:cell_style] = options[:cell_style].merge(width: 28)
            end
            add_align(aligns, options, key) unless aligns.nil?
            arr = make_table([v], options)
            tbody << arr
          end
        else
          begin
            value = ticket.send(f)
          rescue
            value = ""
          end
          value = formated_number(value) if value.class == BigDecimal
          tbody << value
        end
      end
      tbody
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
