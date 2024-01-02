# frozen_string_literal: true

class BCDD::Result
  class CallableAndThen::Config
    attr_accessor :default_method_name_to_call

    def initialize
      self.default_method_name_to_call = :call
    end

    def options
      { default_method_name_to_call: default_method_name_to_call }
    end
  end
end
