# frozen_string_literal: true

require 'securerandom'

class BCDD::Result
  module Transitions
    require_relative 'transitions/tracking'

    THREAD_VAR_NAME = :bcdd_result_transitions_tracking

    def self.tracking
      Thread.current[THREAD_VAR_NAME] ||= Tracking.instance
    end
  end

  def self.transitions(id: SecureRandom.uuid, name: nil, desc: nil)
    Transitions.tracking.start(id: id, name: name, desc: desc)

    result = yield

    result.is_a?(::BCDD::Result) or raise Error::UnexpectedOutcome.build(outcome: result, origin: :transitions)

    Transitions.tracking.finish(id: id, result: result)

    result
  rescue ::Exception => e
    Transitions.tracking.reset!

    raise e
  end
end
