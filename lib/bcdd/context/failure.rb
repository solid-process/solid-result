# frozen_string_literal: true

class BCDD::Context::Failure < BCDD::Context
  include BCDD::Result::Failure::Methods

  def and_expose(_type, _keys, **_options)
    self
  end
end
