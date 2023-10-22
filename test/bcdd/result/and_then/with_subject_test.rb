# frozen_string_literal: true

require 'test_helper'

class BCDD::Result
  class AndThenWithSubjectTest < Minitest::Test
    class Base
      include BCDD::Result.mixin

      attr_reader :arg1, :arg2

      def initialize(arg1, arg2)
        @arg1 = arg1
        @arg2 = arg2
      end

      def call; end

      private

      def validate_numbers
        return Success(:ok) if arg1.is_a?(::Numeric) && arg2.is_a?(::Numeric)

        Failure(:invalid_arg, 'both arguments must be numeric')
      end
    end

    class SubjectMethodArityWithArityZero < Base
      def call
        validate_numbers.and_then(:add)
      end

      private

      def add
        Success(:number, arg1 + arg2)
      end
    end

    class SubjectMethodArityWithArityOne < Base
      def call
        validate_numbers
          .and_then { Success(:ok, [arg1, arg2]) }
          .and_then(:add)
      end

      def add((number1, number2))
        Success(:number, number1 + number2)
      end
    end

    class SubjectMethodArityWithArityTwo < Base
      def call
        context = { number: 3 }

        validate_numbers
          .and_then { Success(:ok, [arg1, arg2]) }
          .and_then(:add, context)
      end

      def add((number1, number2), context)
        Success(:number, number1 + number2 + context.fetch(:number))
      end
    end

    class WrongSubjectMethodArity < Base
      def call
        validate_numbers.and_then(:add)
      end

      def add(number1, number2, _number3)
        Success(:number, number1 + number2)
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
      assert_equal(:number, result.type)
      assert_equal(3, result.value)
    end

    test '#and_then calling a subject method (arity 1)' do
      result = SubjectMethodArityWithArityOne.new(1, 2).call

      assert_predicate(result, :success?)
      assert_equal(:number, result.type)
      assert_equal(3, result.value)
    end

    test '#and_then calling a subject method (arity 2)' do
      result = SubjectMethodArityWithArityTwo.new(1, 2).call

      assert_predicate(result, :success?)
      assert_equal(:number, result.type)
      assert_equal(6, result.value)
    end

    test '#and_then calling a subject method with wrong arity (> 2)' do
      wrong_subject_method_arity = WrongSubjectMethodArity.new(1, 2)

      error = assert_raises(BCDD::Result::Error::WrongSubjectMethodArity) { wrong_subject_method_arity.call }

      expected_message = "#{WrongSubjectMethodArity}#add has unsupported arity (3). Expected 0..2"

      assert_equal(expected_message, error.message)
    end

    test '#and_then raises an error when the block returns a result that does not belongs to the subject' do
      wrong_result_subject = WrongResultSubjectFromBlock.new(1, 2)

      error = assert_raises(BCDD::Result::Error::WrongResultSubject) { wrong_result_subject.call }

      expected_message =
        "You cannot call #and_then and return a result that does not belong to the subject!\n" \
        "Expected subject: #{wrong_result_subject.inspect}\n" \
        "Given subject: #{wrong_result_subject.add_instance.inspect}\n" \
        'Given result: #<BCDD::Result::Success type=:number value=3>'

      assert_equal(expected_message, error.message)
    end

    test '#and_then raises an error when the called method returns a result that does not belongs to the subject' do
      wrong_result_subject = WrongResultSubjectFromMethod.new(1, 2)

      error = assert_raises(BCDD::Result::Error::WrongResultSubject) { wrong_result_subject.call }

      expected_message =
        "You cannot call #and_then and return a result that does not belong to the subject!\n" \
        "Expected subject: #{wrong_result_subject.inspect}\n" \
        "Given subject: #{wrong_result_subject.add_instance.inspect}\n" \
        'Given result: #<BCDD::Result::Success type=:number value=3>'

      assert_equal(expected_message, error.message)
    end

    test '#and_then raises an error when the block returns a non-result object' do
      error = assert_raises(BCDD::Result::Error::UnexpectedOutcome) { UnexpectedBlockOutcome.new(1, 2).call }

      expected_message =
        'Unexpected outcome: 3. The block must return this object wrapped by ' \
        'BCDD::Result::Success or BCDD::Result::Failure'

      assert_equal(expected_message, error.message)
    end

    test '#and_then raises an error when the method returns a non-result object' do
      error = assert_raises(BCDD::Result::Error::UnexpectedOutcome) { UnexpectedMethodOutcome.new(1, 2).call }

      expected_message =
        'Unexpected outcome: 3. The method must return this object wrapped by ' \
        'BCDD::Result::Success or BCDD::Result::Failure'

      assert_equal(expected_message, error.message)
    end
  end
end
