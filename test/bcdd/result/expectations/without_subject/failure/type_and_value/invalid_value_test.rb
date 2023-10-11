# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::ExpectationsWithoutSubjectFailureTypeAndValueInvalidValueTest < Minitest::Test
  class Divide
    Expected = BCDD::Result::Expectations.new(
      failure: {
        invalid_arg: String,
        division_by_zero: String
      }
    )

    def call(arg1, arg2)
      arg1.is_a?(::Numeric) or return Expected::Failure(:invalid_arg, :'arg1 must be numeric')
      arg2.is_a?(::Numeric) or return Expected::Failure(:invalid_arg, :'arg2 must be numeric')

      return Expected::Failure(:division_by_zero, 'arg2 must not be zero') if arg2.zero?

      Expected::Success(:division_completed, (arg1 / arg2).to_s)
    end
  end

  test 'unexpected value error' do
    err = assert_raises(BCDD::Result::Expectations::Error::UnexpectedValue) do
      Divide.new.call(10, '2')
    end

    assert_equal(
      'value :"arg2 must be numeric" is not allowed for :invalid_arg type',
      err.message
    )
  end
end