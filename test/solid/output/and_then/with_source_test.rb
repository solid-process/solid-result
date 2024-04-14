# frozen_string_literal: true

require 'test_helper'

module Solid
  class OutputAndThenWithSourceTest < Minitest::Test
    class Base
      include Solid::Output.mixin

      attr_reader :arg1, :arg2

      def initialize(arg1, arg2)
        @arg1 = arg1
        @arg2 = arg2
      end

      def call; end

      private

      def validate_numbers
        return Success(:ok) if arg1.is_a?(::Numeric) && arg2.is_a?(::Numeric)

        Failure(:invalid_arg, message: 'both arguments must be numeric')
      end
    end

    class SourceMethodArityWithArityZero < Base
      def call
        validate_numbers.and_then(:add)
      end

      private

      def add
        Success(:ok, number: arg1 + arg2)
      end
    end

    class SourceMethodArityWithArityOneKarg < Base
      def call
        validate_numbers
          .and_then { Success(:ok, number1: arg1, number2: arg2) }
          .and_then(:add)
      end

      def add(number1:, number2:)
        Success(:ok, number: number1 + number2)
      end
    end

    class SourceMethodArityWithArityOneArg < Base
      def call
        validate_numbers
          .and_then { Success(:ok, number1: arg1, number2: arg2) }
          .and_then(:add)
      end

      def add(args)
        Success(:ok, number: args)
      end
    end

    class SourceMethodArityWithOutputData < Base
      def call
        validate_numbers
          .and_then { Success(:ok, number1: arg1, number2: arg2) }
          .and_then(:add, number3: 3)
      end

      def add(number1:, number2:, number3:)
        Success(:ok, number: number1 + number2 + number3)
      end
    end

    class InvalidSourceMethodArity < Base
      def call
        validate_numbers.and_then(:add)
      end

      def add(number1, number2)
        Success(:ok, number: number1 + number2)
      end
    end

    class InvalidResultSourceFromBlock < Base
      def add_instance
        @add_instance ||= SourceMethodArityWithArityZero.new(arg1, arg2)
      end

      def call
        validate_numbers.and_then { add_instance.call }
      end
    end

    class InvalidResultSourceFromMethod < Base
      def add_instance
        @add_instance ||= SourceMethodArityWithArityZero.new(arg1, arg2)
      end

      def call
        validate_numbers.and_then(:add)
      end

      def add
        add_instance.call
      end
    end

    class UnexpectedBlockOutcome < Base
      def call
        validate_numbers.and_then { arg1 + arg2 }
      end
    end

    class UnexpectedMethodOutcome < Base
      def call
        validate_numbers.and_then(:add)
      end

      def add
        arg1 + arg2
      end
    end

    test '#and_then calling a source method (arity 0)' do
      result = SourceMethodArityWithArityZero.new(1, 2).call

      assert_predicate(result, :success?)
      assert_equal(:ok, result.type)
      assert_equal({ number: 3 }, result.value)
    end

    test '#and_then calling a source method (arity 1 - keyword args)' do
      result = SourceMethodArityWithArityOneKarg.new(1, 2).call

      assert_predicate(result, :success?)
      assert_equal(:ok, result.type)
      assert_equal({ number: 3 }, result.value)
    end

    test '#and_then calling a source method with context data' do
      result = SourceMethodArityWithOutputData.new(1, 2).call

      assert_predicate(result, :success?)
      assert_equal(:ok, result.type)
      assert_equal({ number: 6 }, result.value)
    end

    test '#and_then calling a source method (arity 1 - positional arg)' do
      invalid_source_method = SourceMethodArityWithArityOneArg.new(1, 2)

      error = assert_raises(Solid::Result::Error::InvalidSourceMethodArity) { invalid_source_method.call }

      assert_match(/#add has unsupported arity \(1\). Expected 0..1\z/, error.message)
    end

    test '#and_then calling a source method with wrong arity (> 1)' do
      wrong_source_method_arity = InvalidSourceMethodArity.new(1, 2)

      error = assert_raises(Solid::Result::Error::InvalidSourceMethodArity) { wrong_source_method_arity.call }

      assert_match(/#add has unsupported arity \(2\). Expected 0..1\z/, error.message)
    end

    test '#and_then raises an error when the block returns a result that does not belongs to the source' do
      wrong_result_source = InvalidResultSourceFromBlock.new(1, 2)

      error = assert_raises(Solid::Result::Error::InvalidResultSource) { wrong_result_source.call }

      expected_message =
        "You cannot call #and_then and return a result that does not belong to the same source!\n" \
        "Expected source: #{wrong_result_source.inspect}\n" \
        "Given source: #{wrong_result_source.add_instance.inspect}\n" \
        'Given result: #<Solid::Output::Success type=:ok value={:number=>3}>'

      assert_equal(expected_message, error.message)
    end

    test '#and_then raises an error when the called method returns a result that does not belongs to the source' do
      wrong_result_source = InvalidResultSourceFromMethod.new(1, 2)

      error = assert_raises(Solid::Result::Error::InvalidResultSource) { wrong_result_source.call }

      expected_message =
        "You cannot call #and_then and return a result that does not belong to the same source!\n" \
        "Expected source: #{wrong_result_source.inspect}\n" \
        "Given source: #{wrong_result_source.add_instance.inspect}\n" \
        'Given result: #<Solid::Output::Success type=:ok value={:number=>3}>'

      assert_equal(expected_message, error.message)
    end

    test '#and_then raises an error when the block returns a non-result object' do
      error = assert_raises(Solid::Result::Error::UnexpectedOutcome) { UnexpectedBlockOutcome.new(1, 2).call }

      expected_message =
        'Unexpected outcome: 3. The block must return this object wrapped by ' \
        'Solid::Output::Success or Solid::Output::Failure'

      assert_equal(expected_message, error.message)
    end

    test '#and_then raises an error when the method returns a non-result object' do
      error = assert_raises(Solid::Result::Error::UnexpectedOutcome) { UnexpectedMethodOutcome.new(1, 2).call }

      expected_message =
        'Unexpected outcome: 3. The method must return this object wrapped by ' \
        'Solid::Output::Success or Solid::Output::Failure'

      assert_equal(expected_message, error.message)
    end
  end
end
