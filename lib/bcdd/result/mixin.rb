# frozen_string_literal: true

class BCDD::Result
  module Mixin
    module Methods
      def Success(type, value = nil)
        Success.new(type: type, value: value, subject: self)
      end

      def Failure(type, value = nil)
        Failure.new(type: type, value: value, subject: self)
      end
    end

  def self.mixin(with: nil)
    mod = Module.new
    mod.send(:include, Mixin::Methods)
    mod
  end

  private_constant :Mixin
end
