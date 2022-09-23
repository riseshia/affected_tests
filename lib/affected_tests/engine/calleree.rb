# frozen_string_literal: true

module AffectedTests
  module Engine
    class Calleree
      def initialize(config)
        @config = config
        @tracing = true

        ::Calleree.start
      end

      def start_trace
        # Clear buffer in calleree
        ::Calleree.result(clear: true)
      end

      def stop_trace
        # do nothing
      end

      def tracing?
        @tracing # Calleree doesn't have tracing status
      end

      def checkpoint(target_test_path)
        res = ::Calleree.result(clear: true)
        import(target_test_path, res)
      end

      def import(target_test_path, result)
        caller_in_project = result.select do |(caller_info, _callee_info, _count)|
          caller_path = caller_info.first
          @config.target_path?(caller_path)
        end.map do |(caller_info, _callee_info, _count)|
          @config.format_path(caller_info.first)
        end

        called_in_project = result.select do |(_caller_info, callee_info, _count)|
          callee_path = callee_info.first
          @config.target_path?(callee_path)
        end.map do |(_caller_info, callee_info, _count)|
          @config.format_path(callee_info.first)
        end

        all_related_paths = (called_in_project + caller_in_project).uniq
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

      def cache
        Thread.current[:cache] ||= {}
      end

      def dump
        cache.transform_values(&:to_a)
      ensure
        ::Calleree.stop
        @tracing = false
      end
    end
  end
end
