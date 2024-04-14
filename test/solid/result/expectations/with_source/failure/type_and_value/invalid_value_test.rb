# frozen_string_literal: true

require 'test_helper'

class Solid::Result::ExpectationsWithSourceFailureTypeAndValueInvalidValueTest < Minitest::Test
  class Divide
    include Solid::Result::Expectations.mixin(
      failure: {
        invalid_arg: String,
        division_by_zero: String
      }
    )

    def call(arg1, arg2)
      arg1.is_a?(::Numeric) or return Failure(:invalid_arg, :'arg1 must be numeric')
      arg2.is_a?(::Numeric) or return Failure(:invalid_arg, :'arg2 must be numeric')

      return Failure(:division_by_zero, 'arg2 must not be zero') if arg2.zero?

      Success(:division_completed, (arg1 / arg2).to_s)
    end
  end

  test 'unexpected value error' do
    err = assert_raises(Solid::Result::Contract::Error::UnexpectedValue) do
      Divide.new.call(10, '2')
    end

    assert_equal(
      'value :"arg2 must be numeric" is not allowed for :invalid_arg type',
      err.message
    )
  end
end
