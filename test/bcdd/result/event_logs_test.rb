# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::EventLogsTest < Minitest::Test
  test 'the unexpected outcome error' do
    err = assert_raises(BCDD::Result::Error::UnexpectedOutcome) do
      BCDD::Result.event_logs { 1 }
    end

    assert_equal(
      'Unexpected outcome: 1. The event_logs must return this object wrapped by ' \
      'BCDD::Result::Success or BCDD::Result::Failure',
      err.message
    )
  end
end
