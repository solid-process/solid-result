# frozen_string_literal: true

class BCDD::Context::Failure < BCDD::Context
  include ::BCDD::Failure

  def and_expose(_type, _keys, **_options)
    self
  end
end
