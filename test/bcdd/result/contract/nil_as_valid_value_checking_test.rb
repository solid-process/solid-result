# frozen_string_literal: true

require 'test_helper'

class BCDD::Result
  class Contract::NiltAsValidValueCheckingTest < Minitest::Test
    test 'BCDD::Result::Expectations' do
      contract = {
        ok: ->(value) {
          case value
          in Numeric then nil
          end
        }
      }

      _Result1 = BCDD::Result::Expectations.new(success: contract)

      assert_raises(Contract::Error::UnexpectedValue) do
        _Result1::Success(:ok, 1)
      end

      BCDD::Result.config.pattern_matching.enable!(:nil_as_valid_value_checking)

      _Result2 = BCDD::Result::Expectations.new(success: contract)

      result = _Result2::Success(:ok, 1)

      assert result.success?(:ok)
      assert_equal(1, result.value)
    ensure
      BCDD::Result.config.pattern_matching.disable!(:nil_as_valid_value_checking)
    end

    test 'BCDD::Context::Expectations' do
      contract = {
        ok: ->(value) {
          case value
          in { number: Numeric } then nil
          end
        }
      }

      _Result1 = BCDD::Context::Expectations.new(success: contract)

      assert_raises(Contract::Error::UnexpectedValue) do
        _Result1::Success(:ok, number: 1)
      end

      BCDD::Result.config.pattern_matching.enable!(:nil_as_valid_value_checking)

      _Result2 = BCDD::Context::Expectations.new(success: contract)

      result = _Result2::Success(:ok, number: 1)

      assert result.success?(:ok)
      assert_equal({ number: 1 }, result.value)
    ensure
      BCDD::Result.config.pattern_matching.disable!(:nil_as_valid_value_checking)
    end
  end
end
