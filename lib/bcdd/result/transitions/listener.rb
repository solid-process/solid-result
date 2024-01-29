# frozen_string_literal: true

module BCDD::Result::Transitions
  module Listener
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
