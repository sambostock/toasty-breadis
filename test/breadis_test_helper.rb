# frozen_string_literal: true
require 'fileutils'

module BreadisTestHelper
  BREADIS_PATH = 'breadis.pstore'

  setup do
    wipe_breadis!
  end

  teardown do
    wipe_breadis!
  end

  private

  def wipe_breadis!
    FileUtils.remove_file(breadis_store.path) if File.exist?(breadis_store.path)
  end

  def breadis_store
    @breadis_store ||= PStore.new('breadis.pstore')
  end
end
