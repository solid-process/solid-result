# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::Context::ExpectationsWithSourceSuccessTypeAndValuePatterMatchingErrorTest < Minitest::Test
  class Divide
    include BCDD::Result::Context::Expectations.mixin(
      success: {
        division_completed: ->(value) {
          case value
          in { number: Numeric } then true
          end
        }
      }
    )

    def call(arg1, arg2)
      arg1.is_a?(::Numeric) or return Failure(:invalid_arg, message: 'arg1 must be numeric')
      arg2.is_a?(::Numeric) or return Failure(:invalid_arg, message: 'arg2 must be numeric')

      return Failure(:division_by_zero, message: 'arg2 must not be zero') if arg2.zero?

      Success(:division_completed, number: (arg1 / arg2).to_s)
    end
  end

  test 'unexpected value error' do
    err = assert_raises(BCDD::Result::Contract::Error::UnexpectedValue) do
      Divide.new.call(10, 2)
    end

    assert_match(
      Regexp.new(
        'value {:number=>"5"} is not allowed for :division_completed type ' \
        '\(.*5.*\)'
      ),
      err.message
    )
  end
end
