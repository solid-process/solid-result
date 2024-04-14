# frozen_string_literal: true

require 'test_helper'

class Solid::Result::EventLogsTest < Minitest::Test
  test 'the unexpected outcome error' do
    err = assert_raises(Solid::Result::Error::UnexpectedOutcome) do
      Solid::Result.event_logs { 1 }
    end

    assert_equal(
      'Unexpected outcome: 1. The event_logs must return this object wrapped by ' \
      'Solid::Result::Success or Solid::Result::Failure',
      err.message
    )
  end
end
