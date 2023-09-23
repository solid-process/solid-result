# frozen_string_literal: true

module BCDD::Result
  class Error < ::StandardError
    NotImplemented = ::Class.new(self)
  end
end
