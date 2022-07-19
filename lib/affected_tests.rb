# frozen_string_literal: true

require "set"
require "json"

require "calleree"

require_relative "affected_tests/version"

module AffectedTests
  module_function

  def setup(project_path:, test_dir_path:, output_path:)
    @project_path = project_path
    @test_dir_path = test_dir_path
    @output_path = output_path
  end

  def start
    Calleree.start
  end

  def import_from_calleree(target_test_path, result)
    caller_in_project = result.select do |(caller_info, _callee_info, _count)|
      caller_path = caller_info.first
      target_path?(caller_path)
    end.map do |(caller_info, _callee_info, _count)|
      format_path(caller_info.first)
    end

    called_in_project = result.select do |(_caller_info, callee_info, _count)|
      callee_path = callee_info.first
      target_path?(callee_path)
    end.map do |(_caller_info, callee_info, _count)|
      format_path(callee_info.first)
    end

    all_related_paths = (called_in_project + caller_in_project).uniq

    target_test_file_path = format_path(target_test_path)

    all_related_paths.each do |path|
      next if path.start_with?(@test_dir_path)

      if path != target_test_file_path
        add(target_test_file_path, path)
      end
    end
  end

  def emit(target_test_path)
    res = Calleree.result(clear: true)
    import_from_calleree(target_test_path, res)
  end

  def dump
    data = { revision: revision, map: cache.transform_values(&:to_a) }
    File.write(@output_path, JSON.dump(data))
  ensure
    Calleree.stop
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

  def revision
    revision_path = File.expand_path("../../REVISION", __FILE__)
    if File.exist?(revision_path)
      File.read(revision_path).strip
    else
      "UNKNOWN"
    end
  end

  def cache
    @cache ||= {}
  end

  def bundler_path
    @bundler_path ||= Bundler.bundle_path.to_s
  end

  def target_path?(path)
    return false if path.nil?

    path.start_with?(@project_path) && !path.start_with?(bundler_path)
  end
end
