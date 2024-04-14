# frozen_string_literal: true

require 'test_helper'

class Solid::Result::ExpectationsWithoutSourceFailureTypeAndValuePatterMatchingErrorTest < Minitest::Test
  class Divide
    Result = Solid::Result::Expectations.new(
      failure: {
        invalid_arg: String,
        division_by_zero: ->(value) do
          case value
          in String then true
          end
        end
      }
    )

    def call(arg1, arg2)
      arg1.is_a?(::Numeric) or return Result::Failure(:invalid_arg, 'arg1 must be numeric')
      arg2.is_a?(::Numeric) or return Result::Failure(:invalid_arg, 'arg2 must be numeric')

      return Result::Failure(:division_by_zero, :'arg2 must not be zero') if arg2.zero?

      Result::Success(:division_completed, (arg1 / arg2).to_s)
    end
  end

  test 'unexpected value error' do
    err = assert_raises(Solid::Result::Contract::Error::UnexpectedValue) do
      Divide.new.call(10, 0)
    end

    assert_match(
      Regexp.new(
        'value :"arg2 must not be zero" is not allowed for :division_by_zero type ' \
        '\(.*arg2 must not be zero.*\)'
      ),
      err.message
    )
  end
end
