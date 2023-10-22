# frozen_string_literal: true

class BCDD::Result
  class Context::Failure < Context
    include Failure::Methods

    def and_expose(_type, _keys)
      self
    end
  end
end
