# frozen_string_literal: true

require 'test_helper'
require 'fileutils'
require 'toaster'

class KitchenTest < ActiveSupport::TestCase
  BREADIS_PATH = 'breadis.pstore'

  setup do
    wipe_breadis!
  end

  teardown do
    wipe_breadis!
  end

  test 'placing and serving a couple orders works' do
    orders = [
      {
        name: 'Jane Doe',
        toppings: %i(butter),
      },
      {
        name: 'John Doe',
        toppings: %i(peanut_butter jam),
      },
      {
        name: 'John Smith',
        toppings: %i(),
      },
    ]

    toasters = 2.times.map { Toaster.new }

    # Place the orders randomly with random toasters
    orders.shuffle.each do |name:, toppings:|
      toasters.sample.order_toast(
        name: name,
        toppings: toppings,
      )
    end

    # Toasters share state, so we can use any toaster at any time
    fulfilled_orders = 3.times.map do
      assert_predicate toasters.sample, :orders_pending?

      toasters.sample.make_toast
    end

    refute_predicate toasters.sample, :orders_pending?

    assert_empty orders - fulfilled_orders
  end

  private

  def wipe_breadis!
    FileUtils.remove_file(breadis_store.path) if File.exist?(breadis_store.path)
  end

  def breadis_store
    @breadis_store ||= PStore.new('breadis.pstore')
  end
end
