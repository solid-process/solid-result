# frozen_string_literal: true

require 'test_helper'

module Solid
  class Output::CallableAndThenArityTest < Minitest::Test
    # rubocop:disable Naming/MethodParameterName
    ProcWithoutKarg = proc { Output::Success(:ok, o: -1) }
    ProcWithOneKarg = proc { |n:| Output::Success(:ok, o: n) }
    ProcWithTwoKargs = proc { |n:, m:| Output::Success(:ok, o: [n, m]) }
    ProcWithArgAndKarg = proc { |foo, bar:| Output::Success(:ok, o: [foo, bar]) }

    LambdaWithoutKarg = -> { Output::Success(:ok, o: -1) }
    LambdaWithOneKarg = ->(n:) { Output::Success(:ok, o: n) }
    LambdaWithTwoKargs = ->(n:, m:) { Output::Success(:ok, o: [n, m]) }
    LambdaWithArgAndKarg = ->(foo, bar:) { Output::Success(:ok, o: [foo, bar]) }

    module ModWithoutKarg
      def self.call; Output::Success(:ok, o: -1); end
    end

    module ModWithOneKarg
      def self.call(n:); Output::Success(:ok, o: n); end
    end

    module ModWithTwoKargs
      def self.call(n:, m:); Output::Success(:ok, o: [n, m]); end
    end

    module ModWithArgAndKarg
      def self.call(foo, bar:); Output::Success(:ok, o: [foo, bar]); end
    end
    # rubocop:enable Naming/MethodParameterName

    def setup
      Solid::Result.config.feature.enable!(:and_then!)
    end

    def teardown
      Solid::Result.config.feature.disable!(:and_then!)
    end

    test 'zero kargs' do
      err1 = assert_raises(Solid::Result::CallableAndThen::Error::InvalidArity) do
        Output::Success(:ok, o: 0).and_then!(ProcWithoutKarg)
      end

      err2 = assert_raises(Solid::Result::CallableAndThen::Error::InvalidArity) do
        Output::Success(:ok, o: 0).and_then!(LambdaWithoutKarg)
      end

      err3 = assert_raises(Solid::Result::CallableAndThen::Error::InvalidArity) do
        Output::Success(:ok, o: 0).and_then!(ModWithoutKarg)
      end

      assert_equal 'Invalid arity for Proc#call method. Expected arity: only keyword args', err1.message
      assert_equal 'Invalid arity for Proc#call method. Expected arity: only keyword args', err2.message
      assert_equal 'Invalid arity for Module#call method. Expected arity: only keyword args', err3.message
    end

    test 'one karg' do
      result1 = Output::Success(:ok, n: 1).and_then!(ProcWithOneKarg)
      result2 = Output::Success(:ok, n: 2).and_then!(LambdaWithOneKarg)
      result3 = Output::Success(:ok, n: 3).and_then!(ModWithOneKarg)

      assert_equal 1, result1.value[:o]
      assert_equal 2, result2.value[:o]
      assert_equal 3, result3.value[:o]
    end

    test 'two kargs' do
      result1 = Output::Success(:ok, n: 1).and_then!(ProcWithTwoKargs, m: 2)
      result2 = Output::Success(:ok, n: 2).and_then!(LambdaWithTwoKargs, m: 3)
      result3 = Output::Success(:ok, n: 3).and_then!(ModWithTwoKargs, m: 4)

      assert_equal([1, 2], result1.value[:o])
      assert_equal([2, 3], result2.value[:o])
      assert_equal([3, 4], result3.value[:o])
    end

    test 'one arg and one karg' do
      err1 = assert_raises(Solid::Result::CallableAndThen::Error::InvalidArity) do
        Output::Success(:ok, o: 0).and_then!(ProcWithArgAndKarg, bar: 1)
      end

      err2 = assert_raises(Solid::Result::CallableAndThen::Error::InvalidArity) do
        Output::Success(:ok, o: 0).and_then!(LambdaWithArgAndKarg, bar: 2)
      end

      err3 = assert_raises(Solid::Result::CallableAndThen::Error::InvalidArity) do
        Output::Success(:ok, o: 0).and_then!(ModWithArgAndKarg, bar: 3)
      end

      assert_equal 'Invalid arity for Proc#call method. Expected arity: only keyword args', err1.message
      assert_equal 'Invalid arity for Proc#call method. Expected arity: only keyword args', err2.message
      assert_equal 'Invalid arity for Module#call method. Expected arity: only keyword args', err3.message
    end
  end
end
