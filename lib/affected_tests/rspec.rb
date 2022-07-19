# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    AffectedTests.start
  end

  config.after(:each) do
    target_spec = self.class.declaration_locations.last[0]
    AffectedTests.emit(target_spec)
  end

  config.after(:suite) do
    AffectedTests.dump
  end
end
