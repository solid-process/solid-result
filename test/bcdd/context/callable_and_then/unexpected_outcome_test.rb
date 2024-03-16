# frozen_string_literal: true

require 'test_helper'

module BCDD
  class Context::CallableAndThenUnexpectedOutcomeTest < Minitest::Test
    ProcWithArg = proc { |arg:| arg }

    module ModWithArg
      def self.call(arg:); arg; end
    end

    def setup
      BCDD::Result.config.feature.enable!(:and_then!)
    end

    def teardown
      BCDD::Result.config.feature.disable!(:and_then!)
    end

    test 'unexpected outcome' do
      err1 = assert_raises(BCDD::Result::CallableAndThen::Error::UnexpectedOutcome) do
        Context::Success(:ok, arg: 0).and_then!(ProcWithArg)
      end

      err2 = assert_raises(BCDD::Result::CallableAndThen::Error::UnexpectedOutcome) do
        Context::Success(:ok, arg: 0).and_then!(ModWithArg)
      end

      expected_kinds = 'BCDD::Context::Success or BCDD::Context::Failure'

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
