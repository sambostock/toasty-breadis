# frozen_string_literal: true

require 'breadis_test_helper'

module ToasterTestHelper
  extend ActiveSupport::Concern
  include BreadisTestHelper

  module ClassMethods
    def each_orderable_toppings
      (0..Toaster::SERVED_TOPPINGS.length).flat_map do |length|
        Toaster::SERVED_TOPPINGS.permutation(length)
      end
    end
  end

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
