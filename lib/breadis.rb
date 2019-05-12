# frozen_string_literal: true

require 'pstore'

module Breadis
  class << self
    def [](key)
      read_only do |store|
        store[key]
      end
    end

    def []=(key, value)
      writeable do |store|
        store[key] = value
      end
    end

    def delete(key)
      writeable do |store|
        store.delete(key)
      end
    end

    def any?
      read_only do |store|
        store.roots.any?
      end
    end

    def random_key
      read_only do |store|
        store.roots.sample
      end
    end

    private

    def writeable
      _store.transaction do
        yield _store
      end
    end

    def read_only
      _store.transaction(true) do
        yield _store
      end
    end

    def _store
      @_store ||= PStore.new('breadis.pstore')
    end
  end
end
