# frozen_string_literal: true

require 'test_helper'

class Solid::Result::ErrorTest < Minitest::Test
  test '::Error' do
    assert Solid::Result::Error < StandardError
  end

  test '::Error.build' do
    hash = [{}, { a: 1 }, { b: 2 }].sample

    error = Solid::Result::Error.build(**hash)

    assert_instance_of Solid::Result::Error, error

    assert_equal Solid::Result::Error.new.message, error.message
  end

  test '::Error::NotImplemented' do
    assert Solid::Result::Error::NotImplemented < Solid::Result::Error
  end

  test '::Error::MissingTypeArgument' do
    assert Solid::Result::Error::MissingTypeArgument < Solid::Result::Error

    assert_equal(
      'A type (argument) is required to invoke the #on/#on_type method',
      Solid::Result::Error::MissingTypeArgument.new.message
    )
  end

  test '::Error::UnexpectedOutcome.build' do
    assert Solid::Result::Error::UnexpectedOutcome < Solid::Result::Error

    error_input = { outcome: { a: 1 }, origin: :block }

    assert_equal(
      'Unexpected outcome: {:a=>1}. The block must return this object wrapped by ' \
      'Solid::Result::Success or Solid::Result::Failure',
      Solid::Result::Error::UnexpectedOutcome.build(**error_input).message
    )
  end

  test '::Error::InvalidResultSource.build' do
    assert Solid::Result::Error::InvalidResultSource < Solid::Result::Error

    given_result = Solid::Result::Success.new(type: :number, value: 3, source: 1)

    error_input = { given_result: given_result, expected_source: 2 }

    assert_equal(
      "You cannot call #and_then and return a result that does not belong to the same source!\n" \
      "Expected source: 2\n" \
      "Given source: 1\n" \
      'Given result: #<Solid::Result::Success type=:number value=3>',
      Solid::Result::Error::InvalidResultSource.build(**error_input).message
    )
  end

  test '::Error::InvalidSourceMethodArity.build' do
    assert Solid::Result::Error::InvalidSourceMethodArity < Solid::Result::Error

    source = Object.new

    def source.do_something(_arg1, _arg2, _arg3); end

    method = source.method(:do_something)

    error_input = { source: source, method: method, max_arity: 2 }

    assert_equal(
      'Object#do_something has unsupported arity (3). Expected 0..2',
      Solid::Result::Error::InvalidSourceMethodArity.build(**error_input).message
    )
  end
end
