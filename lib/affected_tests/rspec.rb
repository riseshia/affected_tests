# frozen_string_literal: true

RSpec.configure do |config|
  config.prepend_before(:each) do
    AffectedTests.start_trace
  end

  config.append_after(:each) do
    AffectedTests.stop_trace
    target_spec = self.class.declaration_locations.last[0]
    # Shared examples are declared outside of the spec file including them,
    # so walk up to the group which the spec file itself declares.
    unless target_spec.end_with?("_spec.rb")
      spec_group = self.class.parent_groups.detect { |group| group.declaration_locations.first[0].end_with?("_spec.rb") }
      target_spec = spec_group.declaration_locations.first[0] if spec_group
    end
    AffectedTests.checkpoint(target_spec)
  end

  config.after(:suite) do
    AffectedTests.dump
  end
end
