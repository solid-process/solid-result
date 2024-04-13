# frozen_string_literal: true

require 'test_helper'

class Solid::Result::EventLogsNotBeenStartedTest < Minitest::Test
  include SolidResultEventLogAssertions

  test 'event_logs is empty by default' do
    success = Solid::Result::Success(:ok, 1)
    failure = Solid::Result::Failure(:err, 0)

    assert_event_logs(success, size: 0)
    assert_event_logs(failure, size: 0)
  end
end
