# frozen_string_literal: true

require 'test_helper'

module BCDD
  class Context::EventLogsNotBeenStartedTest < Minitest::Test
    include BCDDResultEventLogAssertions

    test 'event_logs is empty by default' do
      success = Context::Success(:ok, one: 1)
      failure = Context::Failure(:err, zero: 0)

      assert_event_logs(success, size: 0)
      assert_event_logs(failure, size: 0)
    end
  end
end
