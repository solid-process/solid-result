# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::EventLogsDurationTest < Minitest::Test
  Sleep = -> { sleep(0.1).then { BCDD::Result::Success(:ok) } }

  test '#duration' do
    return unless ENV['BCDD_RESULT_TEST_EVENT_LOGS_DURATION']

    result = BCDD::Result.event_logs do
      Sleep
        .call
        .and_then { Sleep.call }
        .and_then { Sleep.call }
    end

    assert_equal(1, result.event_logs[:version])

    assert_equal(3, result.event_logs[:records].size)

    assert(result.event_logs[:metadata][:duration] > 299)

    assert_equal([0, []], result.event_logs[:metadata][:ids][:tree])
  end
end
