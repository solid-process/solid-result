# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::EventLogsNotBeenStartedTest < Minitest::Test
  include BCDDResultEventLogAssertions

  test 'event_logs is empty by default' do
    success = BCDD::Result::Success(:ok, 1)
    failure = BCDD::Result::Failure(:err, 0)

    assert_event_logs(success, size: 0)
    assert_event_logs(failure, size: 0)
  end
end
