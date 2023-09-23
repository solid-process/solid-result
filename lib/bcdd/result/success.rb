# frozen_string_literal: true

module BCDD
  class Result::Success < Result
    def success?(type = nil)
      type.nil? || type == self.type
    end

    def failure?(_type = nil)
      false
    end
  end
end
