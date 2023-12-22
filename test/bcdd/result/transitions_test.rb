# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::TransitionsTest < Minitest::Test
  test 'the unexpected outcome error' do
    err = assert_raises(BCDD::Result::Error::UnexpectedOutcome) do
      BCDD::Result.transitions { 1 }
    end

    assert_equal(
      'Unexpected outcome: 1. The transitions must return this object wrapped by ' \
      'BCDD::Result::Success or BCDD::Result::Failure',
      err.message
    )
  end
end
