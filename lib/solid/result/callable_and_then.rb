# frozen_string_literal: true

class Solid::Result
  module CallableAndThen
    require_relative 'callable_and_then/error'
    require_relative 'callable_and_then/config'
    require_relative 'callable_and_then/caller'
  end
end
