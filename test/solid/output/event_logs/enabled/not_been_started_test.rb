# frozen_string_literal: true

require 'test_helper'

module Solid
  class Output::EventLogsNotBeenStartedTest < Minitest::Test
    include SolidResultEventLogAssertions

    test 'event_logs is empty by default' do
      success = Output::Success(:ok, one: 1)
      failure = Output::Failure(:err, zero: 0)

      assert_event_logs(success, size: 0)
      assert_event_logs(failure, size: 0)
    end
  end
end
