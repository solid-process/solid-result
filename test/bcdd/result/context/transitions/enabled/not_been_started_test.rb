# frozen_string_literal: true

require 'test_helper'

class BCDD::Result
  class Context::TransitionsNotBeenStartedTest < Minitest::Test
    include BCDDResultTransitionAssertions

    test 'transitions is empty by default' do
      success = Context::Success(:ok, one: 1)
      failure = Context::Failure(:err, zero: 0)

      assert_transitions(success, size: 0)
      assert_transitions(failure, size: 0)
    end
  end
end
