# frozen_string_literal: true
require 'fileutils'

module BreadisTestHelper
  BREADIS_PATH = 'breadis.pstore'

  def self.included(base)
    base.class_eval do
      setup do
        wipe_breadis!
      end

      teardown do
        wipe_breadis!
      end
    end
  end

  private

  def wipe_breadis!
    FileUtils.remove_file(breadis_store.path) if File.exist?(breadis_store.path)
  end

  def breadis_store
    @breadis_store ||= PStore.new('breadis.pstore')
  end
end
