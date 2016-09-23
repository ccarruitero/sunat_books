class Book < Prawn::Document
  include ActiveSupport::NumberHelper

  MONTHS = { 1 => "Enero", 2 => "Febrero", 3 => "marzo", 4 => "abril",
             5 => "mayo", 6 => "junio", 7 => "julio", 8 => "agosto",
             9 => "setiembre", 10 => "octubre", 11 => "noviembre",
             12 => "diciembre" }

  def formated_number float
    # try(number_to_currency(float, unit: ''))
    number_to_currency(float, unit: '')
  end

  def add_align aligns, options, key
    aligns.each do |a|
      if a[key] != nil
        options[:cell_style] = options[:cell_style].merge({align: a[key][0].to_sym})
      end
    end
  end

  def txt txt
    text txt, size: 8
  end

  def sub_head hash, book_name, blayout
    arr = nil
    current_key = nil
    column_widths = {}
    hash.each do |key, value|
      k = I18n.t("books.#{book_name}.#{key}").upcase
      v = value.collect { |s| I18n.t("books.#{book_name}.#{s}").upcase}
      arr = [[{content: k, colspan: value.length}], v]
      current_key = key
    end

    widths = blayout["widths"]
    if !widths.nil?
      widths.each do |w|
        if w[current_key] != nil
          column_widths = w[current_key].flatten
        end
      end
    end
    if column_widths.size != 0
      multihead = make_table( arr, cell_style: {borders: [], size: 5},
                              column_widths: column_widths)
    else
      multihead = make_table( arr,
                              cell_style: {borders: [], size: 5, width: 22})
    end
  end

  def get_period month, year
    "#{MONTHS[month.to_i].upcase} #{year}"
  end

  def book_title title
    text title, align: :center, size: 8
  end

  def book_header period, ruc, name
    move_down 5
    txt "PERIODO: #{period}"
    txt "RUC: #{ruc}"
    txt "APELLIDOS Y NOMBRES, DENOMINACIÓN O RAZÓN SOCIAL: #{name.upcase}"
  end

  def zero
    formated_number(0)
  end
end
