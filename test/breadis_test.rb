# frozen_string_literal: true

require 'test_helper'
require 'fileutils'
require 'breadis'

class BreadisTest < ActiveSupport::TestCase
  BREADIS_PATH = 'breadis.pstore'

  setup do
    wipe_breadis!
  end

  teardown do
    wipe_breadis!
  end

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

  private

  def store(hash)
    breadis_store.transaction do
      hash.each do |key, value|
        breadis_store[key] = value
      end
    end
  end

  def assert_stored(hash)
    breadis_store.transaction(true) do
      hash.each do |key, expected_value|
        stored_value = breadis_store[key]
        message = "The stored value for #{key.inspect} did not match the expected value."

        if expected_value.nil?
          assert_nil stored_value, message
        else
          assert_equal expected_value, stored_value, message
        end
      end
    end
  end

  def wipe_breadis!
    FileUtils.remove_file(breadis_store.path) if File.exist?(breadis_store.path)
  end

  def breadis_store
    @breadis_store ||= PStore.new('breadis.pstore')
  end
end
