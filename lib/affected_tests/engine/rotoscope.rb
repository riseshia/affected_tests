# frozen_string_literal: true

module AffectedTests
  module Engine
    class Rotoscope
      def initialize(config)
        @config = config

        @rotoscope = ::Rotoscope.new do |call|
          next if self == call.receiver

          if call.caller_path && @config.target_path?(call.caller_path)
            buffer << call.caller_path
          end
        end
        @rotoscope.start_trace
      end

      def start_trace
        # Clear buffer
        buffer.clear
      end

      def stop_trace
        # do nothing
      end

      def tracing?
        @rotoscope.tracing?
      end

      def checkpoint(target_test_path)
        diff = buffer
        import(target_test_path, diff)
        buffer.clear
      end

      def import(target_test_path, result)
        all_related_paths = result.uniq.map do |caller_path|
          @config.format_path(caller_path)
        end

        formatted_target_test_path = @config.format_path(target_test_path)

        all_related_paths.each do |path|
          next if path.start_with?(@config.test_dir_path)

          if path != formatted_target_test_path
            add(formatted_target_test_path, path)
          end
        end
      end

      def add(caller, callee)
        cache[callee] ||= Set.new
        cache[callee].add(caller)
      end

      def buffer
        Thread.current[:buffer] ||= []
      end

      def cache
        Thread.current[:cache] ||= {}
      end

      def dump
        @rotoscope.stop_trace
        cache.transform_values(&:to_a)
      end
    end
  end
end
