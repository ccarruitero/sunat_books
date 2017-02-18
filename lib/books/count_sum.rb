module Books
  class CountSum
    def initialize(count_number, initial_value = BigDecimal(0))
      @sum = initial_value
      @count_number = count_number
    end

    def add(value)
      @sum += value
    end

    def count
      @count_number
    end

    def total
      @sum
    end
  end
end
