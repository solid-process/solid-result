# frozen_string_literal: true

module BCDD::Result::Transitions
  class Config
    include ::Singleton

    attr_reader :listener, :trace_id

    def initialize
      @trace_id = -> {}
      @listener = Listener::Null.new
    end

    def listener=(arg)
      Listener.kind?(arg) or raise ::ArgumentError, "#{arg.inspect} must be a #{Listener}"

      @listener = arg
    end

    def trace_id=(arg)
      raise ::ArgumentError, 'must be a lambda with arity 0' unless arg.is_a?(::Proc) && arg.lambda? && arg.arity.zero?

      @trace_id = arg
    end
  end
end
