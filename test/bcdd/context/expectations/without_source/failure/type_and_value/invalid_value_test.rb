# frozen_string_literal: true

require 'test_helper'

class BCDD::Context::ExpectationsWithoutSourceFailureTypeAndValueInvalidValueTest < Minitest::Test
  class Divide
    Result = BCDD::Context::Expectations.new(
      failure: {
        invalid_arg: ->(value) {
          case value
          in { message: String } then true
          end
        },
        division_by_zero: ->(value) {
          case value
          in { message: String } then true
          end
        }
      }
    )

    def call(arg1, arg2)
      arg1.is_a?(::Numeric) or return Result::Failure(:invalid_arg, message: :'arg1 must be numeric')
      arg2.is_a?(::Numeric) or return Result::Failure(:invalid_arg, message: :'arg2 must be numeric')

      return Result::Failure(:division_by_zero, message: 'arg2 must not be zero') if arg2.zero?

      Result::Success(:division_completed, number: (arg1 / arg2).to_s)
    end
  end

  test 'unexpected value error' do
    err = assert_raises(BCDD::Result::Contract::Error::UnexpectedValue) do
      Divide.new.call(10, '2')
    end

    assert_match(
      Regexp.new(
        'value {:message=>:\"arg2 must be numeric\"} is not allowed for :invalid_arg type ' \
        '\(.*arg2 must be numeric.*\)'
      ),
      err.message
    )
  end
end
