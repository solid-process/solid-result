# frozen_string_literal: true

class BCDD::Result
  class Data
    attr_reader :name, :type, :value, :to_h, :to_a

    def initialize(result)
      @name = result.send(:name)
      @type = result.type
      @value = result.value

      @to_h = { name: name, type: type, value: value }
      @to_a = [name, type, value]
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
