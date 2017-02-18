class Ticket
  def initialize(hash)
    hash.each do |key, value|
      define_singleton_method key.to_s do
        value
      end
    end
  end
end
