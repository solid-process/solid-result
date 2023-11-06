# frozen_string_literal: true

require 'singleton'

class BCDD::Result
  class Config
    include Singleton

    require_relative 'config/exposable'

    attr_reader :_exposable

    private :_exposable

    def initialize
      @_exposable = Exposable.new
    end

    def freeze
      _exposable.freeze
      super
    end

    def exposable
      _exposable.options
    end

    def exposed?(option)
      _exposable.enabled?(option)
    end

    def expose!(*options)
      _exposable.enable!(options)
    end

    def unexpose!(*options)
      _exposable.disable!(options)
    end
  end
end
