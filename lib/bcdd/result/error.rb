# frozen_string_literal: true

module BCDD
  class Result::Error < ::StandardError
    NotImplemented = Class.new(self)
  end
end
