# frozen_string_literal: true

require 'test_helper'

module Solid
  class Output::CallableAndThenUnexpectedOutcomeTest < Minitest::Test
    ProcWithArg = proc { |arg:| arg }

    module ModWithArg
      def self.call(arg:); arg; end
    end

    def setup
      Solid::Result.config.feature.enable!(:and_then!)
    end

    def teardown
      Solid::Result.config.feature.disable!(:and_then!)
    end

    test 'unexpected outcome' do
      err1 = assert_raises(Solid::Result::CallableAndThen::Error::UnexpectedOutcome) do
        Output::Success(:ok, arg: 0).and_then!(ProcWithArg)
      end

      err2 = assert_raises(Solid::Result::CallableAndThen::Error::UnexpectedOutcome) do
        Output::Success(:ok, arg: 0).and_then!(ModWithArg)
      end

      expected_kinds = 'Solid::Output::Success or Solid::Output::Failure'

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
