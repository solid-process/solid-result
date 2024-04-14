# frozen_string_literal: true

class Solid::Output::Failure < Solid::Output
  include ::Solid::Failure

  def and_expose(_type, _keys, **_options)
    self
  end
end
