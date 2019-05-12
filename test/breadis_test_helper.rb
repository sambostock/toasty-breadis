# frozen_string_literal: true
require 'fileutils'

module BreadisTestHelper
  extend ActiveSupport::Concern

  BREADIS_PATH = 'breadis.pstore'

  included do
    setup do
      wipe_breadis!
    end

    teardown do
      wipe_breadis!
    end
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
