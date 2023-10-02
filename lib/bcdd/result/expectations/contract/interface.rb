# frozen_string_literal: true

module BCDD::Result::Expectations::Contract
  module Interface
    def allowed_types
      raise BCDD::Result::Error::NotImplemented
    end

    def type?(_type)
      raise BCDD::Result::Error::NotImplemented
    end

    def type!(_type)
      raise BCDD::Result::Error::NotImplemented
    end

    def type_and_value!(_data)
      raise BCDD::Result::Error::NotImplemented
    end
  end
end
