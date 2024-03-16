# frozen_string_literal: true

require 'test_helper'

module BCDD::Result::EventLogs
  class ListenerTest < Minitest::Test
    module ModuleListener
      extend Listener
    end

    class ClassListener
      include Listener
    end

    test '.around_event_logs?' do
      refute_predicate ModuleListener, :around_event_logs?

      refute_predicate ClassListener, :around_event_logs?
    end

    test '.around_and_then?' do
      refute_predicate ModuleListener, :around_and_then?

      refute_predicate ClassListener, :around_and_then?
    end
  end
end
