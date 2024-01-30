# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::Config
  class FeatureTransitionsTraceIdTest < Minitest::Test
    include BCDDResultTransitionAssertions

    test 'valid trace_id config' do
      original_trace_id = BCDD::Result.config.transitions.trace_id

      random_number = rand

      BCDD::Result.config.transitions.trace_id = -> { random_number }

      result = nil

      BCDD::Result.transitions do
        result = BCDD::Result::Success(:ok, 1)
      end

      assert_equal(random_number, result.transitions.dig(:metadata, :trace_id))

      assert_transitions(result, size: 1, trace_id: random_number)
    ensure
      BCDD::Result.config.transitions.trace_id = original_trace_id
    end

    test 'invalid trace_id config' do
      err = assert_raises(ArgumentError) do
        BCDD::Result.config.transitions.trace_id = 'invalid'
      end

      assert_equal('must be a lambda with arity 0', err.message)
    end
  end
end
