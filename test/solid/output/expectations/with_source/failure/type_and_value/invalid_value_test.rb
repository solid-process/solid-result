# frozen_string_literal: true

require 'test_helper'

class Solid::Output::ExpectationsWithSourceFailureTypeAndValueInvalidValueTest < Minitest::Test
  class Divide
    include Solid::Output::Expectations.mixin(
      failure: {
        invalid_arg: ->(value) { value.is_a?(Hash) && value[:message].is_a?(String) },
        division_by_zero: ->(value) { value.is_a?(Hash) && value[:message].is_a?(String) }
      }
    )

    def call(arg1, arg2)
      arg1.is_a?(::Numeric) or return Failure(:invalid_arg, message: :'arg1 must be numeric')
      arg2.is_a?(::Numeric) or return Failure(:invalid_arg, message: :'arg2 must be numeric')

      return Failure(:division_by_zero, message: 'arg2 must not be zero') if arg2.zero?

      Success(:division_completed, number: (arg1 / arg2).to_s)
    end
  end

  test 'unexpected value error' do
    err = assert_raises(Solid::Result::Contract::Error::UnexpectedValue) do
      Divide.new.call(10, '2')
    end

    assert_equal(
      'value {:message=>:"arg2 must be numeric"} is not allowed for :invalid_arg type',
      err.message
    )
  end
end
