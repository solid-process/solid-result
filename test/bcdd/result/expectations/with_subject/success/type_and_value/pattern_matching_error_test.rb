# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::ExpectationsWithSubjectSuccessTypeAndValuePatterMatchingErrorTest < Minitest::Test
  class Divide
    include BCDD::Result::Expectations.mixin(
      success: {
        division_completed: ->(value) do
          case value
          in (Integer | Float) then true
          end
        end
      }
    )

    def call(arg1, arg2)
      arg1.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg1 must be numeric')
      arg2.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg2 must be numeric')

      return Failure(:division_by_zero, 'arg2 must not be zero') if arg2.zero?

      Success(:division_completed, (arg1 / arg2).to_s)
    end
  end

  test 'unexpected value error' do
    err = assert_raises(BCDD::Result::Expectations::Contract::Error::UnexpectedValue) do
      Divide.new.call(10, 2)
    end

    assert_equal(
      'value "5" is not allowed for :division_completed type',
      err.message
    )
  end
end
