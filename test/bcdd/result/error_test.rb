# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::ErrorTest < Minitest::Test
  test '::Error' do
    assert BCDD::Result::Error < StandardError
  end

  test '::Error.build' do
    hash = [{}, { a: 1 }, { b: 2 }].sample

    error = BCDD::Result::Error.build(**hash)

    assert_instance_of BCDD::Result::Error, error

    assert_equal BCDD::Result::Error.new.message, error.message
  end

  test '::Error::NotImplemented' do
    assert BCDD::Result::Error::NotImplemented < BCDD::Result::Error
  end

  test '::Error::MissingTypeArgument' do
    assert BCDD::Result::Error::MissingTypeArgument < BCDD::Result::Error

    assert_equal(
      'A type (argument) is required to invoke the #on/#on_type method',
      BCDD::Result::Error::MissingTypeArgument.new.message
    )
  end

  test '::Error::UnexpectedOutcome.build' do
    assert BCDD::Result::Error::UnexpectedOutcome < BCDD::Result::Error

    error_input = { outcome: { a: 1 }, origin: :block }

    assert_equal(
      'Unexpected outcome: {:a=>1}. The block must return this object wrapped by ' \
      'BCDD::Result::Success or BCDD::Result::Failure',
      BCDD::Result::Error::UnexpectedOutcome.build(**error_input).message
    )
  end

  test '::Error::WrongResultSubject.build' do
    assert BCDD::Result::Error::WrongResultSubject < BCDD::Result::Error

    given_result = BCDD::Result::Success.new(type: :number, value: 3, subject: 1)

    error_input = { given_result: given_result, expected_subject: 2 }

    assert_equal(
      "You cannot call #and_then and return a result that does not belong to the subject!\n" \
      "Expected subject: 2\n" \
      "Given subject: 1\n" \
      'Given result: #<BCDD::Result::Success type=:number value=3>',
      BCDD::Result::Error::WrongResultSubject.build(**error_input).message
    )
  end

  test '::Error::WrongSubjectMethodArity.build' do
    assert BCDD::Result::Error::WrongSubjectMethodArity < BCDD::Result::Error

    subject = 'string'

    method = subject.method(:tr)

    error_input = { subject: subject, method: method }

    assert_equal(
      'String#tr has unsupported arity (2). Expected 0 or 1.',
      BCDD::Result::Error::WrongSubjectMethodArity.build(**error_input).message
    )
  end
end
