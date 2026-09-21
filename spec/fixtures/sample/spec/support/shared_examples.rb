# frozen_string_literal: true

RSpec.shared_examples "shared" do
  it "calls shared" do
    expect(Sample.new.shared).to eq(:shared)
  end
end
