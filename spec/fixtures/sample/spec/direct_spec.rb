# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Sample do
  it "calls direct" do
    expect(described_class.new.direct).to eq(:direct)
  end
end
