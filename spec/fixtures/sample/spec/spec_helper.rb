# frozen_string_literal: true

require "affected_tests"
require "affected_tests/rspec"

AffectedTests.setup(
  engine: ENV.fetch("AFFECTED_TESTS_ENGINE").to_sym,
  project_path: File.expand_path("..", __dir__),
  test_dir_path: "spec/",
  output_path: ENV.fetch("AFFECTED_TESTS_OUTPUT_PATH"),
  revision: "sample"
)

require_relative "../lib/sample"
require_relative "support/shared_examples"
