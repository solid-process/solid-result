# frozen_string_literal: true

require 'test_helper'

class BCDD::Result
  class ContextAndThenWithSubjectTest < Minitest::Test
    class Base
      include BCDD::Result::Context.mixin

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

    class SubjectMethodArityWithArityZero < Base
      def call
        validate_numbers.and_then(:add)
      end

      private

      def add
        Success(:ok, number: arg1 + arg2)
      end
    end

    class SubjectMethodArityWithArityOneKarg < Base
      def call
        validate_numbers
          .and_then { Success(:ok, number1: arg1, number2: arg2) }
          .and_then(:add)
      end

      def add(number1:, number2:)
        Success(:ok, number: number1 + number2)
      end
    end

    class SubjectMethodArityWithArityOneArg < Base
      def call
        validate_numbers
          .and_then { Success(:ok, number1: arg1, number2: arg2) }
          .and_then(:add)
      end

      def add(args)
        Success(:ok, number: args)
      end
    end

    class SubjectMethodArityWithContextData < Base
      def call
        validate_numbers
          .and_then { Success(:ok, number1: arg1, number2: arg2) }
          .and_then(:add, number3: 3)
      end

      def add(number1:, number2:, number3:)
        Success(:ok, number: number1 + number2 + number3)
      end
    end

    class WrongSubjectMethodArity < Base
      def call
        validate_numbers.and_then(:add)
      end

      def add(number1, number2)
        Success(:ok, number: number1 + number2)
      end
    end

    class WrongResultSubjectFromBlock < Base
      def add_instance
        @add_instance ||= SubjectMethodArityWithArityZero.new(arg1, arg2)
      end

      def call
        validate_numbers.and_then { add_instance.call }
      end
    end

    class WrongResultSubjectFromMethod < Base
      def add_instance
        @add_instance ||= SubjectMethodArityWithArityZero.new(arg1, arg2)
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

    test '#and_then calling a subject method (arity 0)' do
      result = SubjectMethodArityWithArityZero.new(1, 2).call

      assert_predicate(result, :success?)
      assert_equal(:ok, result.type)
      assert_equal({ number: 3 }, result.value)
    end

    test '#and_then calling a subject method (arity 1 - keyword args)' do
      result = SubjectMethodArityWithArityOneKarg.new(1, 2).call

      assert_predicate(result, :success?)
      assert_equal(:ok, result.type)
      assert_equal({ number: 3 }, result.value)
    end

    test '#and_then calling a subject method with context data' do
      result = SubjectMethodArityWithContextData.new(1, 2).call

      assert_predicate(result, :success?)
      assert_equal(:ok, result.type)
      assert_equal({ number: 6 }, result.value)
    end

    test '#and_then calling a subject method (arity 1 - positional arg)' do
      invalid_subject_method = SubjectMethodArityWithArityOneArg.new(1, 2)

      error = assert_raises(BCDD::Result::Error::WrongSubjectMethodArity) { invalid_subject_method.call }

      assert_match(/#add has unsupported arity \(1\). Expected 0..1\z/, error.message)
    end

    test '#and_then calling a subject method with wrong arity (> 1)' do
      wrong_subject_method_arity = WrongSubjectMethodArity.new(1, 2)

      error = assert_raises(BCDD::Result::Error::WrongSubjectMethodArity) { wrong_subject_method_arity.call }

      assert_match(/#add has unsupported arity \(2\). Expected 0..1\z/, error.message)
    end

    test '#and_then raises an error when the block returns a result that does not belongs to the subject' do
      wrong_result_subject = WrongResultSubjectFromBlock.new(1, 2)

      error = assert_raises(BCDD::Result::Error::WrongResultSubject) { wrong_result_subject.call }

      expected_message =
        "You cannot call #and_then and return a result that does not belong to the subject!\n" \
        "Expected subject: #{wrong_result_subject.inspect}\n" \
        "Given subject: #{wrong_result_subject.add_instance.inspect}\n" \
        'Given result: #<BCDD::Result::Context::Success type=:ok value={:number=>3}>'

      assert_equal(expected_message, error.message)
    end

    test '#and_then raises an error when the called method returns a result that does not belongs to the subject' do
      wrong_result_subject = WrongResultSubjectFromMethod.new(1, 2)

      error = assert_raises(BCDD::Result::Error::WrongResultSubject) { wrong_result_subject.call }

      expected_message =
        "You cannot call #and_then and return a result that does not belong to the subject!\n" \
        "Expected subject: #{wrong_result_subject.inspect}\n" \
        "Given subject: #{wrong_result_subject.add_instance.inspect}\n" \
        'Given result: #<BCDD::Result::Context::Success type=:ok value={:number=>3}>'

      assert_equal(expected_message, error.message)
    end

    test '#and_then raises an error when the block returns a non-result object' do
      error = assert_raises(BCDD::Result::Error::UnexpectedOutcome) { UnexpectedBlockOutcome.new(1, 2).call }

      expected_message =
        'Unexpected outcome: 3. The block must return this object wrapped by ' \
        'BCDD::Result::Context::Success or BCDD::Result::Context::Failure'

      assert_equal(expected_message, error.message)
    end

    test '#and_then raises an error when the method returns a non-result object' do
      error = assert_raises(BCDD::Result::Error::UnexpectedOutcome) { UnexpectedMethodOutcome.new(1, 2).call }

      expected_message =
        'Unexpected outcome: 3. The method must return this object wrapped by ' \
        'BCDD::Result::Context::Success or BCDD::Result::Context::Failure'

      assert_equal(expected_message, error.message)
    end
  end
end
