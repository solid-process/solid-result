# frozen_string_literal: true

class BCDD::Result
  module Contract::Interface
    def allowed_types
      raise Error::NotImplemented
    end

    def type?(_type)
      raise Error::NotImplemented
    end

    def type!(_type)
      raise Error::NotImplemented
    end

    def type_and_value!(_data)
      raise Error::NotImplemented
    end
  end
end
