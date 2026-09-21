# frozen_string_literal: true

require "json"
require "open3"
require "tmpdir"

RSpec.describe "affected_tests/rspec" do
  let(:fixture_path) { File.expand_path("fixtures/sample", __dir__) }
  let(:lib_path) { File.expand_path("../lib", __dir__) }

  def run_fixture_specs(engine:, spec_paths:)
    Dir.mktmpdir do |dir|
      output_path = File.join(dir, "map.json")
      env = { "AFFECTED_TESTS_ENGINE" => engine.to_s, "AFFECTED_TESTS_OUTPUT_PATH" => output_path }
      output, status = Open3.capture2e(env, "bundle", "exec", "rspec", "-I", lib_path, *spec_paths, chdir: fixture_path)
      raise output unless status.success?

      JSON.parse(File.read(output_path))
    end
  end

  %i[rotoscope calleree coverage].each do |engine|
    context "with #{engine} engine" do
      it "maps a source file to the spec file which used it" do
        result = run_fixture_specs(engine:, spec_paths: ["spec/direct_spec.rb"])

        expect(result).to eq("revision" => "sample", "map" => { "lib/sample.rb" => ["spec/direct_spec.rb"] })
      end

      it "maps a source file to the spec file including shared examples, not to the shared examples file" do
        result = run_fixture_specs(engine:, spec_paths: ["spec/shared_spec.rb"])

        expect(result).to eq("revision" => "sample", "map" => { "lib/sample.rb" => ["spec/shared_spec.rb"] })
      end

      it "maps a source file to every spec file which used it" do
        result = run_fixture_specs(engine:, spec_paths: ["spec/direct_spec.rb", "spec/shared_spec.rb"])

        expect(result.fetch("map").fetch("lib/sample.rb")).to contain_exactly("spec/direct_spec.rb", "spec/shared_spec.rb")
      end
    end
  end
end
