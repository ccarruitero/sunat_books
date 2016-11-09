require_relative 'helper'

scope do
  test 'book_code' do
    base = PleBooks::Base.new
    assert base.book_code("8.1") == "080100"
    assert base.book_code("3.1") == "030100"
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

    # test 'generate zip file' do
    # end
  end
end
