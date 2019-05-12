# frozen_string_literal: true

require 'breadis'

class Toaster
  SERVED_TOPPINGS = %i(
    butter
    jam
    peanut_butter
  )

  DuplicateToppings = Class.new(StandardError)
  ToppingsNotServed = Class.new(StandardError)
  ExistingOrder = Class.new(StandardError)

  def order_toast(name:, toppings:)
    no_duplicate_toppings!(toppings)
    all_toppings_served!(toppings)
    no_existing_order!(name)

    Breadis[name] = toppings
  end

  def orders_pending?
    Breadis.any?
  end

  def make_toast
    name = Breadis.random_key
    return unless name

    {
      name: name,
      toppings: Breadis.delete(name),
    }
  end

  private

  def no_duplicate_toppings!(toppings)
    return if toppings.length == toppings.uniq.length

    raise DuplicateToppings, toppings.inspect
  end

  def all_toppings_served!(toppings)
    unknown_toppings = toppings - SERVED_TOPPINGS
    return if unknown_toppings.empty?

    raise ToppingsNotServed, unknown_toppings.inspect
  end

  def no_existing_order!(name)
    existing_order = Breadis[name]
    return unless existing_order

    raise ExistingOrder, "#{existing_order.inspect} for #{name}"
  end
end
