# frozen_string_literal: true

module BCDD::Result::Transitions
  module Listener
    module ClassMethods
      def around_transitions?
        false
      end

      def around_and_then?
        false
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def self.extended(base)
      base.extend(ClassMethods)
    end

    def self.kind?(arg)
      (arg.is_a?(::Class) && arg < self) || (arg.is_a?(::Module) && arg.is_a?(self)) || arg.is_a?(Listeners::Chain)
    end

    def on_start(scope:); end

    def around_transitions(scope:)
      yield
    end

    def around_and_then(scope:, and_then:)
      yield
    end

    def on_record(record:); end

    def on_finish(transitions:); end

    def before_interruption(exception:, transitions:); end
  end

  module Listener::Null
    extend Listener

    def self.new
      self
    end
  end
end
