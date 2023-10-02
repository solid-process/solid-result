# frozen_string_literal: true

class BCDD::Result
  class Data
    attr_reader :name, :type, :value

    def initialize(name, type, value)
      @name = name
      @type = type
      @value = value
    end

    def to_h
      { name: name, type: type, value: value }
    end

    def to_a
      [name, type, value]
    end

    def inspect
      format(
        '#<%<class_name>s name=%<name>p type=%<type>p value=%<value>p>',
        class_name: self.class.name, name: name, type: type, value: value
      )
    end

    alias to_ary to_a
    alias to_hash to_h
  end

  private_constant :Data
end
