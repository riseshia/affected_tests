# frozen_string_literal: true

require "affected_tests"
require "affected_tests/differ"
require "affected_tests/map_merger"

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.order = :random
  Kernel.srand config.seed
end
