# frozen_string_literal: true

module BCDD
  class Result::Failure < Result
    def success?(_type = nil)
      false
    end

    def failure?(type = nil)
      type.nil? || type == self.type
    end
  end
end
