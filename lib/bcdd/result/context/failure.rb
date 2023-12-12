# frozen_string_literal: true

class BCDD::Result::Context::Failure < BCDD::Result::Context
  include BCDD::Result::Failure::Methods

  def and_expose(_type, _keys, **_options)
    self
  end
end
