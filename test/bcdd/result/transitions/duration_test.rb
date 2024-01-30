# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::TransitionsDurationTest < Minitest::Test
  Sleep = -> { sleep(0.1).then { BCDD::Result::Success(:ok) } }

  test '#duration' do
    return unless ENV['BCDD_RESULT_TEST_TRANSITIONS_DURATION']

    result = BCDD::Result.transitions do
      Sleep
        .call
        .and_then { Sleep.call }
        .and_then { Sleep.call }
    end

    assert_equal(1, result.transitions[:version])

    assert_equal(3, result.transitions[:records].size)

    assert(result.transitions[:metadata][:duration] > 299)

    assert_equal([0, []], result.transitions[:metadata][:ids_tree])
  end
end
