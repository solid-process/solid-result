# frozen_string_literal: true

require 'test_helper'

class BCDD::Result
  class Context::TransitionsNotBeenStartedTest < Minitest::Test
    test 'transitions is empty by default' do
      success = Context::Success(:ok, one: 1)
      failure = Context::Failure(:err, zero: 0)

      assert_instance_of(Array, success.transitions)
      assert(success.transitions.empty? && success.transitions.frozen?)

      assert_instance_of(Array, failure.transitions)
      assert(failure.transitions.empty? && failure.transitions.frozen?)
    end
  end
end
