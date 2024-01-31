# frozen_string_literal: true

class BCDD::Result
  module IgnoredTypes
    LIST = ::Set[
      GIVEN = :_given_,
      CONTINUE = :_continue_
    ].freeze

    def self.include?(type)
      LIST.member?(type)
    end
  end
end
