# frozen_string_literal: true

require "set"
require "json"

require "rotoscope"

require_relative "affected_tests/version"

module AffectedTests
  module_function

  def setup(project_path:, test_dir_path:, output_path:, revision: nil)
    @project_path = project_path
    @test_dir_path = test_dir_path
    @output_path = output_path
    @revision = revision || build_revision
    @rotoscope = Rotoscope.new do |call|
      next if self == call.receiver

      if call.caller_path && target_path?(call.caller_path)
        buffer << call.caller_path
      end
    end
  end

  def start_trace
    @rotoscope.start_trace
  end

  def stop_trace
    @rotoscope.stop_trace
  end

  def import_from_rotoscope(target_test_path, result)
    all_related_paths = result.uniq.map do |caller_path|
      format_path(caller_path)
    end

    formatted_target_test_path = format_path(target_test_path)

    all_related_paths.each do |path|
      next if path.start_with?(@test_dir_path)

      if path != formatted_target_test_path
        add(formatted_target_test_path, path)
      end
    end
  end

  def checkpoint(target_test_path)
    diff = buffer
    import_from_rotoscope(target_test_path, diff)
    buffer.clear
  end

  def dump
    data = { revision: @revision, map: cache.transform_values(&:to_a) }
    File.write(@output_path, JSON.dump(data))
  ensure
    @rotoscope.stop_trace if @rotoscope.tracing?
  end

  def format_path(path)
    if path&.start_with?(@project_path)
      path.sub(@project_path + "/", "")
    else
      path
    end
  end

  def add(caller, callee)
    cache[callee] ||= Set.new
    cache[callee].add(caller)
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

  def buffer
    Thread.current[:buffer] ||= []
  end

  def cache
    Thread.current[:cache] ||= {}
  end

  def bundler_path
    @bundler_path ||= Bundler.bundle_path.to_s
  end

  def target_path?(path)
    return false if path.nil?

    path.start_with?(@project_path) && !path.start_with?(bundler_path)
  end
end
