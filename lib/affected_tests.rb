# frozen_string_literal: true

require "set"
require "json"

require_relative "affected_tests/version"

module AffectedTests
  class Configuration
    attr_reader :project_path, :bundler_path, :test_dir_path, :output_path, :revision

    def initialize(project_path:, test_dir_path:, output_path:, revision:)
      @project_path = project_path
      @test_dir_path = test_dir_path
      @bundler_path = Bundler.bundle_path.to_s
      @output_path = output_path
      @revision = revision
    end

    def format_path(path)
      if path&.start_with?(@project_path)
        path.sub(@project_path + "/", "")
      else
        path
      end
    end

    def target_path?(path)
      return false if path.nil?

      path.start_with?(@project_path) && !path.start_with?(@bundler_path)
    end
  end

  module_function

  def setup(engine: :rotoscope, project_path:, test_dir_path:, output_path:, revision: nil)
    @config = Configuration.new(
      project_path: project_path,
      output_path: output_path,
      revision: revision,
      test_dir_path: test_dir_path
    )

    @engine = select_engine(engine).new(@config)
  end

  def select_engine(engine)
    case engine
    when :rotoscope
      require "rotoscope"
      require "affected_tests/engine/rotoscope"
      AffectedTests::Engine::Rotoscope
    when :calleree
      require "calleree"
      require "affected_tests/engine/calleree"
      AffectedTests::Engine::Calleree
    when :coverage
      require "coverage"
      require "affected_tests/engine/coverage"
      AffectedTests::Engine::Coverage
    else
      raise "Unknown engine: #{engine}"
    end
  end

  def start_trace
    @engine.start_trace
  end

  def stop_trace
    @engine.stop_trace
  end

  def checkpoint(target_test_path)
    @engine.checkpoint(target_test_path)
  end

  def dump
    data = { revision: @config.revision || build_revision, map: @engine.dump }
    File.write(@config.output_path, JSON.dump(data))
  ensure
    @engine.stop_trace if @engine.tracing?
  end

  def build_revision
    if defined? Rails
      path = Rails.root.join("REVISION")
      if path.exist?
        path.read.chomp
      else
        "UNKNOWN"
      end
    else
      "UNKNOWN"
    end
  end
end
