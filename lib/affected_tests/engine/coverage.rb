# frozen_string_literal: true

module AffectedTests
  module Engine
    class Coverage
      def initialize(config)
        @config = config

        ::Coverage.start(lines: true)
      end

      def start_trace
        # Clear buffer in coverage
        ::Coverage.result(stop: false, clear: true)
      end

      def stop_trace
        # Do nothing
      end

      def tracing?
        ::Coverage.running?
      end

      def checkpoint(target_test_path)
        result = ::Coverage.result(stop: false, clear: true)
        actual_used = result.select do |_file_path, coverage|
          coverage[:lines].any? { |line| line && line > 0 }
        end
        import(target_test_path, actual_used.keys)
      end

      def import(target_test_path, used_file_paths)
        all_related_paths = used_file_paths.select do |file_path|
          @config.target_path?(file_path)
        end

        formatted_target_test_path = @config.format_path(target_test_path)

        all_related_paths.each do |path|
          formatted_path = @config.format_path(path)

          next if formatted_path.start_with?(@config.test_dir_path)

          if formatted_path != formatted_target_test_path
            add(formatted_target_test_path, formatted_path)
          end
        end
      end

      def add(caller, callee)
        cache[callee] ||= Set.new
        cache[callee].add(caller)
      end

      def cache
        Thread.current[:cache] ||= {}
      end

      def dump
        ::Coverage.result(stop: true, clear: true)

        cache.transform_values(&:to_a)
      end
    end
  end
end
