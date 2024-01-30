# frozen_string_literal: true

class BCDD::Result
  module Transitions
    require_relative 'transitions/tree'
    require_relative 'transitions/tracking'
    require_relative 'transitions/config'

    THREAD_VAR_NAME = :bcdd_result_transitions_tracking

    EnsureResult = ->(result) do
      return result if result.is_a?(::BCDD::Result)

      raise Error::UnexpectedOutcome.build(outcome: result, origin: :transitions)
    end

    def self.tracking
      Thread.current[THREAD_VAR_NAME] ||= Tracking.instance
    end
  end

  def self.transitions(name: nil, desc: nil, &block)
    Transitions.tracking.exec(name, desc, &block)
  end
end
