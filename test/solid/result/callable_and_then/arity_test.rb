# frozen_string_literal: true

require 'test_helper'

class Solid::Result
  class CallableAndThenArityTest < Minitest::Test
    ProcWithoutArg = proc { Solid::Result::Success(:ok, -1) }
    ProcWithOneArg = proc { |arg| Solid::Result::Success(:ok, arg) }
    ProcWithTwoArgs = proc { |arg1, arg2| Solid::Result::Success(:ok, [arg1, arg2]) }
    ProcWithThreeArgs = proc { |arg1, arg2, arg3| Solid::Result::Success(:ok, [arg1, arg2, arg3]) }

    LambdaWithoutArg = -> { Solid::Result::Success(:ok, -1) }
    LambdaWithOneArg = ->(arg) { Solid::Result::Success(:ok, arg) }
    LambdaWithTwoArgs = ->(arg1, arg2) { Solid::Result::Success(:ok, [arg1, arg2]) }
    LambdaWithThreeArgs = ->(arg1, arg2, arg3) { Solid::Result::Success(:ok, [arg1, arg2, arg3]) }

    module ModWithoutArg
      def self.call; Solid::Result::Success(:ok, -1); end
    end

    module ModWithOneArg
      def self.call(arg); Solid::Result::Success(:ok, arg); end
    end

    module ModWithTwoArgs
      def self.call(arg1, arg2); Solid::Result::Success(:ok, [arg1, arg2]); end
    end

    module ModWithThreeArgs
      def self.call(arg1, arg2, arg3); Solid::Result::Success(:ok, [arg1, arg2, arg3]); end
    end

    def setup
      Solid::Result.config.feature.enable!(:and_then!)
    end

    def teardown
      Solid::Result.config.feature.disable!(:and_then!)
    end

    test 'arity zero' do
      err1 = assert_raises(Solid::Result::CallableAndThen::Error::InvalidArity) do
        Solid::Result::Success(:ok, 0).and_then!(ProcWithoutArg)
      end

      err2 = assert_raises(Solid::Result::CallableAndThen::Error::InvalidArity) do
        Solid::Result::Success(:ok, 0).and_then!(LambdaWithoutArg)
      end

      err3 = assert_raises(Solid::Result::CallableAndThen::Error::InvalidArity) do
        Solid::Result::Success(:ok, 0).and_then!(ModWithoutArg)
      end

      assert_equal 'Invalid arity for Proc#call method. Expected arity: 1..2', err1.message
      assert_equal 'Invalid arity for Proc#call method. Expected arity: 1..2', err2.message
      assert_equal 'Invalid arity for Module#call method. Expected arity: 1..2', err3.message
    end

    test 'arity one' do
      result1 = Solid::Result::Success(:ok, 1).and_then!(ProcWithOneArg)
      result2 = Solid::Result::Success(:ok, 2).and_then!(LambdaWithOneArg)
      result3 = Solid::Result::Success(:ok, 3).and_then!(ModWithOneArg)

      assert(result1.success?(:ok))
      assert_equal 1, result1.value

      assert(result2.success?(:ok))
      assert_equal 2, result2.value

      assert(result3.success?(:ok))
      assert_equal 3, result3.value
    end

    test 'arity two' do
      result1 = Solid::Result::Success(:ok, 1).and_then!(ProcWithTwoArgs, 2)
      result2 = Solid::Result::Success(:ok, 2).and_then!(LambdaWithTwoArgs, 3)
      result3 = Solid::Result::Success(:ok, 3).and_then!(ModWithTwoArgs, 4)

      assert(result1.success?(:ok))
      assert_equal [1, 2], result1.value

      assert(result2.success?(:ok))
      assert_equal [2, 3], result2.value

      assert(result3.success?(:ok))
      assert_equal [3, 4], result3.value
    end

    test 'arity greater than or equal to three' do
      err1 = assert_raises(Solid::Result::CallableAndThen::Error::InvalidArity) do
        Solid::Result::Success(:ok, 0).and_then!(ProcWithThreeArgs, 1)
      end

      err2 = assert_raises(Solid::Result::CallableAndThen::Error::InvalidArity) do
        Solid::Result::Success(:ok, 0).and_then!(LambdaWithThreeArgs, 1)
      end

      err3 = assert_raises(Solid::Result::CallableAndThen::Error::InvalidArity) do
        Solid::Result::Success(:ok, 0).and_then!(ModWithThreeArgs, 1)
      end

      assert_equal 'Invalid arity for Proc#call method. Expected arity: 1..2', err1.message
      assert_equal 'Invalid arity for Proc#call method. Expected arity: 1..2', err2.message
      assert_equal 'Invalid arity for Module#call method. Expected arity: 1..2', err3.message
    end
  end
end
