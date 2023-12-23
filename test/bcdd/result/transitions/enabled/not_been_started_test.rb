# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::TransitionsNotBeenStartedTest < Minitest::Test
  test 'transitions is empty by default' do
    success = BCDD::Result::Success(:ok, 1)
    failure = BCDD::Result::Failure(:err, 0)

    assert_instance_of(Array, success.transitions)
    assert(success.transitions.empty? && success.transitions.frozen?)

    assert_instance_of(Array, failure.transitions)
    assert(failure.transitions.empty? && failure.transitions.frozen?)
  end
end
