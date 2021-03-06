# frozen_string_literal: true

require 'test_helper'
require 'breadis_test_helper'
require 'breadis'

class BreadisTest < ActiveSupport::TestCase
  include BreadisTestHelper

  test '.[] reads a key from the store' do
    expected = 123
    key = 'abc'

    store key => expected

    assert_equal expected, Breadis[key]
  end

  test '.[] returns nil if the key is not found' do
    assert_nil Breadis['abc']
  end

  test '.[]= sets the value for a key' do
    value = 123
    key = 'abc'

    Breadis[key] = value

    assert_stored(key => value)
  end

  test '.delete returns the value for a key' do
    key = 'abc'
    value = 123
    store key => value

    assert_equal value, Breadis.delete(key)
  end

  test '.delete returns nil if the key does not exist' do
    assert_nil Breadis.delete('abc')
  end

  test '.delete deletes the key' do
    key = 'abc'
    store key => 123

    Breadis.delete(key)

    assert_stored key => nil
  end

  test '.random_key returns nil if no keys' do
    assert_nil Breadis.random_key
  end

  test '.random_key returns the only key if only one key' do
    key = 'abc'
    store key => 'value'

    assert_equal key, Breadis.random_key
  end

  test '.random_key returns one of the keys if there are many' do
    hash = 3.times.map { |n| ["key-#{n}", "value-#{n}"] }.to_h
    store hash

    assert_includes hash.keys, Breadis.random_key
  end

  test '.random_key eventually picks from all keys' do
    hash = 3.times.map { |n| ["key-#{n}", "value-#{n}"] }.to_h
    store hash

    sampled_keys = 54.times.map { Breadis.random_key }

    assert_empty hash.keys - sampled_keys, 'some keys were never sampled'
  end

  test '.any? returns true if there are any stored keys' do
    store 'abc' => 123

    assert_predicate Breadis, :any?
  end

  test '.any? returns false if there are no stored keys' do
    refute_predicate Breadis, :any?
  end
end
