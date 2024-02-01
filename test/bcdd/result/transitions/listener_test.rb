# frozen_string_literal: true

require 'test_helper'

module BCDD::Result::Transitions
  class ListenerTest < Minitest::Test
    module ModuleListener
      extend Listener
    end

    class ClassListener
      include Listener
    end

    test '.around_transitions?' do
      refute_predicate ModuleListener, :around_transitions?

      refute_predicate ClassListener, :around_transitions?
    end

    test '.around_and_then?' do
      refute_predicate ModuleListener, :around_and_then?

      refute_predicate ClassListener, :around_and_then?
    end
  end
end
