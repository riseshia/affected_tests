# frozen_string_literal: true

module AffectedTests
  module Engine
    class Coverage
      def initialize(&block)
        @rotoscope = ::Rotoscope.new(&block)
      end

      def start_trace
        @rotoscope.start_trace
      end

      def stop_trace
        @rotoscope.stop_trace
      end

      def tracing?
        @rotoscope.tracing?
      end
    end
  end
end
