# frozen_string_literal: true

require "json"
require "tmpdir"

RSpec.describe AffectedTests::Differ do
  describe ".run" do
    let(:map) do
      {
        "lib/foo.rb" => ["spec/foo_spec.rb", "spec/integration_spec.rb"],
        "lib/bar.rb" => ["spec/bar_spec.rb", "spec/integration_spec.rb"]
      }
    end

    def run(diff)
      Dir.mktmpdir do |dir|
        diff_file_path = File.join(dir, "diff.json")
        map_file_path = File.join(dir, "map.json")
        File.write(diff_file_path, JSON.dump(diff))
        File.write(map_file_path, JSON.dump(revision: "rev", map:))

        described_class.run(diff_file_path:, map_file_path:, test_dir_path: "spec/")
      end
    end

    it "returns tests associated with a modified code" do
      result = run([{ filename: "lib/foo.rb", status: "modified" }])

      expect(result).to contain_exactly("spec/foo_spec.rb", "spec/integration_spec.rb")
    end

    it "returns tests associated with a deleted code" do
      result = run([{ filename: "lib/bar.rb", status: "deleted" }])

      expect(result).to contain_exactly("spec/bar_spec.rb", "spec/integration_spec.rb")
    end

    it "ignores an added code" do
      result = run([{ filename: "lib/baz.rb", status: "added" }])

      expect(result).to be_empty
    end

    it "ignores a modified code which no test is associated with" do
      result = run([{ filename: "lib/unknown.rb", status: "modified" }])

      expect(result).to be_empty
    end

    it "returns added and modified tests" do
      result = run([
        { filename: "spec/new_spec.rb", status: "added" },
        { filename: "spec/foo_spec.rb", status: "modified" }
      ])

      expect(result).to contain_exactly("spec/new_spec.rb", "spec/foo_spec.rb")
    end

    it "ignores a deleted test even if a changed code is associated with it" do
      result = run([
        { filename: "lib/foo.rb", status: "modified" },
        { filename: "spec/foo_spec.rb", status: "deleted" }
      ])

      expect(result).to contain_exactly("spec/integration_spec.rb")
    end

    it "returns each test once even if several changes point to it" do
      result = run([
        { filename: "lib/foo.rb", status: "modified" },
        { filename: "lib/bar.rb", status: "modified" },
        { filename: "spec/foo_spec.rb", status: "modified" }
      ])

      expect(result).to contain_exactly("spec/foo_spec.rb", "spec/bar_spec.rb", "spec/integration_spec.rb")
    end

    it "returns nothing for an empty diff" do
      expect(run([])).to be_empty
    end
  end
end
