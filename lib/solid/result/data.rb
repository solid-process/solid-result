# frozen_string_literal: true

class Solid::Result
  class Data
    attr_reader :kind, :type, :value

    def initialize(kind, type, value)
      @kind = kind
      @type = type.to_sym
      @value = value
    end

    def to_h
      { kind: kind, type: type, value: value }
    end

    def to_a
      [kind, type, value]
    end

    def inspect
      format(
        '#<%<class_name>s kind=%<kind>p type=%<type>p value=%<value>p>',
        class_name: self.class.name, kind: kind, type: type, value: value
      )
    end

    alias to_ary to_a
    alias to_hash to_h
  end

  private_constant :Data
end
