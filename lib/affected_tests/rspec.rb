# frozen_string_literal: true

RSpec.configure do |config|
  config.prepend_before(:each) do
    AffectedTests.start_trace
  end

  config.append_after(:each) do
    AffectedTests.stop_trace
    target_spec = self.class.declaration_locations.last[0]
    AffectedTests.checkpoint(target_spec)
  end

  config.after(:suite) do
    AffectedTests.dump
  end
end
