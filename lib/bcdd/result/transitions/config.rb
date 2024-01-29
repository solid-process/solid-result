# frozen_string_literal: true

module BCDD::Result::Transitions
  require_relative 'listener'

  class Config
    include ::Singleton

    attr_reader :listener, :trace_id

    def initialize
      @trace_id = -> {}
      @listener = Listener::Null.new
    end

    def listener=(arg)
      unless (arg.is_a?(::Class) && arg < Listener) || arg.is_a?(Listener)
        raise ::ArgumentError, "#{arg.inspect} must be a #{Listener}"
      end

      @listener = arg
    end

    def trace_id=(arg)
      raise ::ArgumentError, 'must be a lambda with arity 0' unless arg.is_a?(::Proc) && arg.lambda? && arg.arity.zero?

      @trace_id = arg
    end
  end
end
