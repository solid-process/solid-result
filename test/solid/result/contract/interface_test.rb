# frozen_string_literal: true

require 'test_helper'

class Solid::Result
  class Contract::InterfaceTest < Minitest::Test
    test '#allowed_types' do
      object = Object.new.extend(Contract::Interface)

      assert_raises(Error::NotImplemented) do
        object.allowed_types
      end
    end

    test '#type?' do
      object = Object.new.extend(Contract::Interface)

      assert_raises(Error::NotImplemented) do
        object.type?(:ok)
      end
    end

    test '#type!' do
      object = Object.new.extend(Contract::Interface)

      assert_raises(Error::NotImplemented) do
        object.type!(:ok)
      end
    end

    test '#type_and_value!' do
      data = Solid::Result::Success(:ok, 'value').data

      object = Object.new.extend(Contract::Interface)

      assert_raises(Error::NotImplemented) do
        object.type_and_value!(data)
      end
    end
  end
end
