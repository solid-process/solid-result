# frozen_string_literal: true

require 'test_helper'

class BCDD::Result
  class CallableAndThenUnexpectedOutcomeTest < Minitest::Test
    ProcWithArg = proc { |arg| arg }

    module ModWithArg
      def self.call(arg); arg; end
    end

    def setup
      BCDD::Result.config.feature.enable!(:and_then!)
    end

    def teardown
      BCDD::Result.config.feature.disable!(:and_then!)
    end

    test 'unexpected outcome' do
      err1 = assert_raises(BCDD::Result::CallableAndThen::Error::UnexpectedOutcome) do
        BCDD::Result::Success(:ok, 0).and_then!(ProcWithArg)
      end

      err2 = assert_raises(BCDD::Result::CallableAndThen::Error::UnexpectedOutcome) do
        BCDD::Result::Success(:ok, 0).and_then!(ModWithArg)
      end

      expected_kinds = 'BCDD::Result::Success or BCDD::Result::Failure'

      assert_match(
        /Unexpected outcome: 0. The #<Proc:.+> must return this object wrapped by #{expected_kinds}/,
        err1.message
      )

      assert_match(
        /Unexpected outcome: 0. The .+::ModWithArg must return this object wrapped by #{expected_kinds}/,
        err2.message
      )
    end
  end
end
