# frozen_string_literal: true

require 'test_helper'

module BCDD::Result::Expectations
  class ContractInterfaceTest < Minitest::Test
    test '#allowed_types' do
      object = Object.new.extend(Contract::Interface)

      assert_raises(BCDD::Result::Error::NotImplemented) do
        object.allowed_types
      end
    end

    test '#type?' do
      object = Object.new.extend(Contract::Interface)

      assert_raises(BCDD::Result::Error::NotImplemented) do
        object.type?(:ok)
      end
    end

    test '#type!' do
      object = Object.new.extend(Contract::Interface)

      assert_raises(BCDD::Result::Error::NotImplemented) do
        object.type!(:ok)
      end
    end

    test '#type_and_value!' do
      data = BCDD::Result::Success(:ok, 'value').data

      object = Object.new.extend(Contract::Interface)

      assert_raises(BCDD::Result::Error::NotImplemented) do
        object.type_and_value!(data)
      end
    end
  end
end
