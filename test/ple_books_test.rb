require_relative 'helper'

scope do
  setup do
    @base = PleBooks::Base.new
  end

  test 'book_code' do
    assert @base.book_code('8.1') == '080100'
    assert @base.book_code('3.1') == '030100'
  end

  test 'ple_book_name' do
    name = @base.ple_book_name('8.1', '10201902912', 2015, 11)
    assert name.length == 33

    name = @base.ple_book_name('8.1', '10201902912', 2015, 11, nil, 0)
    assert name.length == 33
    assert name[30] == '0'

    name = @base.ple_book_name('8.1', '10201902912', 2015, 11, nil, nil, 2)
    assert name.length == 33
    assert name[31] == '2'
  end

  test 'get_file' do
    fields = []
    3.times { fields << random_string(String.public_methods) }

    tickets = []
    3.times do
      hash = {}
      fields.each { |field| hash.merge!("#{field}": SecureRandom.hex(2)) }
      tickets << Ticket.new(hash)
    end

    filename = "#{@base.path}/some_file.txt"
    @base.get_file(tickets, fields, filename)

    assert File.exists?(filename)

    file_str = File.read(filename)
    assert file_str.count("\n") == 3
    assert file_str.split("\n").first == get_line(fields, tickets.first)
    assert file_str.split("\n").last == get_line(fields, tickets.last)
  end

  scope 'buys' do

    setup do
      tickets = [{}]
      ruc = '102392839213'
      @ple_buys = PleBooks::Buys.new(ruc, tickets, 10, 2013)
    end

    test 'generate txt file' do
      assert File.exists?(@ple_buys.instance_variable_get('@filename'))
    end

    test 'tickets empty' do
      ple_buys = PleBooks::Buys.new('10293827481', {}, 10, 2011)
      assert File.exists?(ple_buys.instance_variable_get('@filename'))
    end

    scope 'custom layout' do
      test 'allow custom file for layout' do
        dir = File.dirname(__FILE__)
        yml = "#{dir}/fixtures/custom_layout.yml"
        tickets = []
        field_value = SecureRandom.hex(10)
        tickets << Ticket.new(custom_field: field_value)
        ple_buys = PleBooks::Buys.new('10293827481', tickets, 10, 2011, yml)
        file = ple_buys.instance_variable_get('@filename')
        assert File.exists?(file)

        txt = File.read(file)
        assert txt.include?(field_value)
      end

      test 'allow change individual field' do
      end
    end

    # test 'generate zip file' do
    # end
  end
end
