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

  test '::Error::InvalidResultSource.build' do
    assert BCDD::Result::Error::InvalidResultSource < BCDD::Result::Error

    given_result = BCDD::Result::Success.new(type: :number, value: 3, source: 1)

    error_input = { given_result: given_result, expected_source: 2 }

    assert_equal(
      "You cannot call #and_then and return a result that does not belong to the same source!\n" \
      "Expected source: 2\n" \
      "Given source: 1\n" \
      'Given result: #<BCDD::Result::Success type=:number value=3>',
      BCDD::Result::Error::InvalidResultSource.build(**error_input).message
    )
  end

  test '::Error::InvalidSourceMethodArity.build' do
    assert BCDD::Result::Error::InvalidSourceMethodArity < BCDD::Result::Error

    source = Object.new

    def source.do_something(_arg1, _arg2, _arg3); end

    method = source.method(:do_something)

    error_input = { source: source, method: method, max_arity: 2 }

    assert_equal(
      'Object#do_something has unsupported arity (3). Expected 0..2',
      BCDD::Result::Error::InvalidSourceMethodArity.build(**error_input).message
    )
  end
end
