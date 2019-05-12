# frozen_string_literal: true

module ToasterTestHelper
  private

  def place(order_or_orders)
    orders = normalize_hashes(order_or_orders)

    orders.each do |name:, toppings:|
      store name => toppings
    end
  end

  def assert_placed(order_or_orders)
    orders = normalize_hashes(order_or_orders)

    orders.each do |name:, toppings:|
      assert_stored name => toppings
    end
  end

  def normalize_hashes(hash_or_hashes)
    if hash_or_hashes.is_a? Hash
      [hash_or_hashes]
    else
      hash_or_hashes
    end
  end

  def toaster
    @toaster ||= Toaster.new
  end
end
