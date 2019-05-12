# frozen_string_literal: true

require 'test_helper'
require 'breadis_test_helper'
require 'toaster_test_helper'
require 'toaster'

class ToasterTest < ActiveSupport::TestCase
  include BreadisTestHelper
  include ToasterTestHelper

  each_orderable_toppings do |toppings|
    test "#order_toast accepts #{toppings.inspect} as toppings" do
      toaster.order_toast(
        name: 'Jane Doe',
        toppings: toppings,
      )
    end
  end

  test '#order_toast stores orders' do
    name = 'Jane Doe'
    toppings = %i(peanut_butter jam)

    toaster.order_toast(
      name: name,
      toppings: toppings,
    )

    assert_placed(
      name: name,
      toppings: toppings,
    )
  end

  test '#order_toast rejects orders with duplicate toppings' do
    toppings = %i(jam jam)

    error = assert_raises Toaster::DuplicateToppings do
      toaster.order_toast(
        name: 'Jane Doe',
        toppings: toppings,
      )
    end

    assert_equal toppings.inspect, error.message
  end

  test '#order_toast rejects orders with unknown toppings' do
    toppings = %i(butter glue)

    error = assert_raises Toaster::ToppingsNotServed do
      toaster.order_toast(
        name: 'Jane Doe',
        toppings: toppings,
      )
    end

    assert_equal %i(glue).inspect, error.message
  end

  test '#order_toast rejects a second order if one is pending' do
    name = 'Jane Doe'
    toppings = %i(peanut_butter jam)
    place(
      name: name,
      toppings: toppings,
    )

    error = assert_raises Toaster::ExistingOrder do
      toaster.order_toast(
        name: name,
        toppings: %i(butter),
      )
    end

    assert_equal "#{toppings.inspect} for #{name}", error.message
  end

  test '#orders_pending? is true if there are orders pending' do
    place(
      name: 'Jane Doe',
      toppings: [],
    )

    assert_predicate toaster, :orders_pending?
  end

  test '#orders_pending? is false if there are no orders pending' do
    refute_predicate toaster, :orders_pending?
  end

  test '#make_toast returns nil if no orders are pending' do
    assert_nil toaster.make_toast
  end

  test '#make_toast makes one of the pending orders' do
    order = {
      name: 'Jane Doe',
      toppings: %(butter),
    }

    place order

    assert_equal order, toaster.make_toast
  end

  test '#make_toast removes the made order from the pending list' do
    orders = [
      {
        name: 'Jane Doe',
        toppings: %i(butter),
      },
      {
        name: 'John Doe',
        toppings: %i(peanut_butter jam),
      },
    ]

    orders.each { |order| place order }

    fulfilled_order = toaster.make_toast

    remaining_orders = orders - [fulfilled_order]

    assert_placed remaining_orders
  end
end
