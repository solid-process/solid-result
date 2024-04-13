# frozen_string_literal: true

require 'test_helper'

class Solid::Result
  class Contract::NiltAsValidValueCheckingTest < Minitest::Test
    test 'Solid::Result::Expectations' do
      contract = {
        ok: ->(value) {
          case value
          in Numeric then nil
          end
        }
      }

      _Result1 = Solid::Result::Expectations.new(success: contract)

      assert_raises(Contract::Error::UnexpectedValue) do
        _Result1::Success(:ok, 1)
      end

      Solid::Result.config.pattern_matching.enable!(:nil_as_valid_value_checking)

      _Result2 = Solid::Result::Expectations.new(success: contract)

      result = _Result2::Success(:ok, 1)

      assert result.success?(:ok)
      assert_equal(1, result.value)
    ensure
      Solid::Result.config.pattern_matching.disable!(:nil_as_valid_value_checking)
    end

    test 'Solid::Output::Expectations' do
      contract = {
        ok: ->(value) {
          case value
          in { number: Numeric } then nil
          end
        }
      }

      _Result1 = Solid::Output::Expectations.new(success: contract)

      assert_raises(Contract::Error::UnexpectedValue) do
        _Result1::Success(:ok, number: 1)
      end

      Solid::Result.config.pattern_matching.enable!(:nil_as_valid_value_checking)

      _Result2 = Solid::Output::Expectations.new(success: contract)

      result = _Result2::Success(:ok, number: 1)

      assert result.success?(:ok)
      assert_equal({ number: 1 }, result.value)
    ensure
      Solid::Result.config.pattern_matching.disable!(:nil_as_valid_value_checking)
    end
  end
end
