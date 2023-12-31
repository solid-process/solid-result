# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::TransitionsNotBeenStartedTest < Minitest::Test
  include BCDDResultTransitionAssertions

  test 'transitions is empty by default' do
    success = BCDD::Result::Success(:ok, 1)
    failure = BCDD::Result::Failure(:err, 0)

    assert_transitions(success, size: 0)
    assert_transitions(failure, size: 0)
  end
end
