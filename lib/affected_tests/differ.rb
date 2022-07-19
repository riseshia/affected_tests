# frozen_string_literal: true

require "json"
require "set"

module AffectedTests
  module Differ
    module_function

    # target calculate policy:
    # codes:
    #   added: ignore(if user write test, which covers it)
    #   modified: execute associated test
    #   deleted: execute associated test
    # tests:
    #   added: execute it
    #   modified: execute it
    #   deleted: ignore
    def run(diff_file_path:, map_file_path:, test_dir_path:)
      diff = JSON.parse(File.read(diff_file_path))
      map_info = JSON.parse(File.read(map_file_path))
      map = map_info["map"]

      added_codes = []
      modified_codes = []
      deleted_codes = []

      added_tests = []
      modified_tests = []
      deleted_tests = []

      diff.each do |diff_info|
        path = diff_info["filename"]
        if path.start_with?(test_dir_path)
          case diff_info["status"]
          when "added"
            added_tests << path
          when "modified"
            modified_tests << path
          when "deleted"
            deleted_tests << path
          end
        else
          case diff_info["status"]
          when "added"
            added_codes << path
          when "modified"
            modified_codes << path
          when "deleted"
            deleted_codes << path
          end
        end
      end

      target_tests_set = Set.new

      (modified_codes + deleted_codes).each do |path|
        list = map[path] || []

        list.each do |suspect_test_path|
          target_tests_set << suspect_test_path
        end
      end

      (added_tests + modified_tests).each do |path|
        target_tests_set << path
      end

      target_tests_set.to_a - deleted_tests
    end
  end
end
