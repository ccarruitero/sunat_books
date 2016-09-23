require 'yaml'

class SalesBook < Book
  def initialize(company, tickets, view, month, year)
    super(page_layout: :landscape, margin: [5], page_size: "A4")
    @view = view
    @company = company
    @period = get_period(month, year)
    @pages = {}
    @tickets = tickets
    @book_name = self.class.name.downcase.sub("book", "")
    dir = File.dirname(__FILE__)
    @blayout = YAML.load_file("#{dir}/layouts/#{@book_name}.yml")
    repeat(:all) do
      canvas do
        bounding_box([bounds.left + 10, bounds.top - 10], width: 800) do
          book_title "REGISTRO DE VENTAS"
          book_header @period, @company.ruc, @company.name
        end
      end
    end

    bounding_box([bounds.left + 3, bounds.top - 45], width: 790, height: 510) do
      book_body
    end

    repeat(:all, dynamic: true) do
      canvas do
        bounding_box([235, 50], width: 700) do
          book_footer
        end
      end
    end
  end

  def book_body
    length = @tickets.length
    page_num = (length / 28.0).ceil
    page_num.times do |i|
      @pages[i + 1] = {
        page_number: i + 1,
        length: 0,
        bi_sum: BigDecimal(0)
      }
    end

    move_down 5
    fields = @blayout["headers"]
    widths = @blayout["widths"]
    aligns = @blayout["align"]
    thead = []
    fields.each do |h|
      if h.class == Hash
        r = sub_head(h, @book_name, @blayout)
        thead << r
      else
        thead << I18n.t("books.#{@book_name}.#{h}").upcase
      end
    end
    data = [thead]

    n = 1
    bi_sum = BigDecimal(0)
    igv_sum = BigDecimal(0)
    total_sum = BigDecimal(0)
    non_taxable = BigDecimal(0)

    @tickets.each do |ticket|
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
            options = {cell_style: {borders: [], size: 5}}
            column_widths = nil
            if !widths.nil?
              widths.each do |w|
                if w[key] != nil
                  column_widths = w[key].flatten
                end
              end
            end
            if column_widths != nil
              options = options.merge({column_widths: column_widths})
            else
              options[:cell_style] = options[:cell_style].merge({width: 28})
            end
            if !aligns.nil?
              add_align(aligns, options, key)
            end
            arr = make_table( [v], options)
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
      data << tbody

      if @pages[n][:length] < 28
        page = @pages[n]
        page[:length] += 1
      else
        page = @pages[n + 1]
        n += 1
        page[:length] += 1
      end

      bi_sum += ticket.taxable_bi
      igv_sum += ticket.igv
      total_sum += ticket.total_operation_sales
      page[:bi_sum] = bi_sum.round(2)
      page[:igv_sum] = igv_sum.round(2)
      page[:total_sum] = total_sum.round(2)
    end

    table(data, header: true, cell_style: {borders: [], size: 5, align: :right},
          column_widths: {0 => 22, 1 => 35, 2 => 30, 5 => 22, 6 => 35, 8 => 20,
                          9 => 30, 10 => 20, 11 => 35, 12 => 29})
  end

  def book_footer
    arr = []
    if page_count == page_number
      letter = "TOTAL"
    else
      letter = "VAN"
    end

    bi_sum= formated_number(@pages[page_number][:bi_sum].to_f)
    igv_sum= formated_number(@pages[page_number][:igv_sum].to_f)
    total_sum= formated_number(@pages[page_number][:total_sum].to_f)

    if @pages[page_number - 1] != nil
      letter1 = "VIENEN"
      p = @pages[page_number - 1]
      bi_sum1 = formated_number(p[:bi_sum].to_f)
      igv_sum1 = formated_number(p[:igv_sum].to_f)
      total_sum1 = formated_number(p[:total_sum].to_f)
      arr << [letter1, zero, bi_sum1, zero, zero, zero, igv_sum1, zero, total_sum1]
    end
    arr << [letter, zero, bi_sum, zero, zero, zero, igv_sum, zero, total_sum]
    table( arr, cell_style: {align: :right, borders: [], size: 5}, column_widths: [50, 22, 35, 22, 22, 20, 30 ,20, 35])
  end
end
