# frozen_string_literal: true

RSpec.describe AffectedTests do
  describe ".select_engine" do
    it "raises for an unknown engine" do
      expect { described_class.select_engine(:unknown) }.to raise_error("Unknown engine: unknown")
    end
  end

  describe AffectedTests::Configuration do
    let(:config) do
      described_class.new(
        project_path: "/app",
        test_dir_path: "spec/",
        output_path: "log/affected-tests-map.json",
        revision: "rev"
      )
    end

    describe "#format_path" do
      it "returns a path relative to the project for a path inside the project" do
        expect(config.format_path("/app/lib/foo.rb")).to eq("lib/foo.rb")
      end

      it "returns the path as it is for a path outside of the project" do
        expect(config.format_path("/other/lib/foo.rb")).to eq("/other/lib/foo.rb")
      end

      it "returns nil for nil" do
        expect(config.format_path(nil)).to be_nil
      end
    end

    describe "#target_path?" do
      it "is true for a path inside the project" do
        expect(config.target_path?("/app/lib/foo.rb")).to be(true)
      end

      it "is false for a path outside of the project" do
        expect(config.target_path?("/other/lib/foo.rb")).to be(false)
      end

      it "is false for nil" do
        expect(config.target_path?(nil)).to be(false)
      end

      it "is false for a gem installed inside the project" do
        allow(Bundler).to receive(:bundle_path).and_return(Pathname("/app/vendor/bundle"))

        expect(config.target_path?("/app/vendor/bundle/gems/foo/lib/foo.rb")).to be(false)
      end
    end
  end
end
