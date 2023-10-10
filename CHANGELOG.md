## [Unreleased]

## [0.5.0] - 2023-10-09

### Added

- Add `BCDD::Result::Expectations` to define contracts for your results. There are two ways to use it: the standalone (`BCDD::Result::Expectations.new`) and the mixin (`BCDD::Result::Expectations.mixin`) mode.

The main difference is that the mixin mode will use the target object (who receives the include/extend) as the result's subject (like the `BCDD::Result::Mixin` does), while the standalone mode won't.

**Standalone mode:**

```ruby
module Divide
  Expected = BCDD::Result::Expectations.new(
    success: {
      numbers: ->(value) { value.is_a?(Array) && value.size == 2 && value.all?(Numeric) },
      division_completed: Numeric
    },
    failure: {
      invalid_arg: String,
      division_by_zero: String
    }
  )

  def self.call(arg1, arg2)
    arg1.is_a?(Numeric) or return Expected::Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(Numeric) or return Expected::Failure(:invalid_arg, 'arg2 must be numeric')

    arg2.zero? and return Expected::Failure(:division_by_zero, 'arg2 must not be zero')

    Expected::Success(:division_completed, arg1 / arg2)
  end
end
```

**Mixin mode:**

```ruby
class Divide
  include BCDD::Result::Expectations.mixin(
    success: {
      numbers: ->(value) { value.is_a?(Array) && value.size == 2 && value.all?(Numeric) },
      division_completed: Numeric
    },
    failure: {
      invalid_arg: String,
      division_by_zero: String
    }
  )

  def call(arg1, arg2)
    validate_numbers(arg1, arg2)
      .and_then(:validate_non_zero)
      .and_then(:divide)
  end

  private

  def validate_numbers(arg1, arg2)
    arg1.is_a?(Numeric) or return Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(Numeric) or return Failure(:invalid_arg, 'arg2 must be numeric')

    Success(:numbers, [arg1, arg2])
  end

  def validate_non_zero(numbers)
    return Success(:numbers, numbers) unless numbers.last.zero?

    Failure(:division_by_zero, 'arg2 must not be zero')
  end

  def divide((number1, number2))
    Success(:division_completed, number1 / number2)
  end
end
```

## [0.4.0] - 2023-09-28

### Added

- Add `require 'result'` to define `Result` as an alias for `BCDD::Result`.

- Add support to pattern matching (Ruby 2.7+).

- Add `BCDD::Result#on_unknown` to execute a block if no other hook (`#on`, `#on_type`, `#on_failure`, `#on_success`) has been executed. Attention: always use it as the last hook.

- Add `BCDD::Result::Handler#unknown` to execute a block if no other handler (`#[]`, `#type`, `#failure`, `#success`) has been executed. Attention: always use it as the last handler.

### Changed

- **(BREAKING)** Rename `BCDD::Resultable` to `BCDD::Result::Mixin`.

- **(BREAKING)** Change `BCDD::Result#data` to return a `BCDD::Result::Data` instead of the result value. This object exposes the result attributes (name, type, value) directly and as a hash (`to_h`/`to_hash`) and array (`to_a`/`to_ary`).

### Removed

- **(BREAKING)** Remove `BCDD::Result#data_or`.

## [0.3.0] - 2023-09-26

### Added

- Add `BCDD::Result#handle`. This method allows defining blocks for each hook (type, failure, success), but instead of returning the result itself, it will return the output of the first match/block execution.

## [0.2.0] - 2023-09-26

### Added

- Add `BCDD::Resultable`. This module can add `Success()` and `Failure()` in any object. The target object will be the subject of the result object produced by these methods.

**Classes (instance methods)**

```ruby
class Divide
  include BCDD::Resultable

  attr_reader :arg1, :arg2

  def initialize(arg1, arg2)
    @arg1 = arg1
    @arg2 = arg2
  end

  def call
    validate_numbers
      .and_then(:validate_non_zero)
      .and_then(:divide)
  end

  private

  def validate_numbers
    arg1.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg2 must be numeric')

    Success(:ok, [arg1, arg2])
  end

  def validate_non_zero(numbers)
    return Success(:ok, numbers) unless numbers.last.zero?

    Failure(:division_by_zero, 'arg2 must not be zero')
  end

  def divide((number1, number2))
    Success(:division_completed, number1 / number2)
  end
end
```

**Module (singleton methods)**

```ruby
module Divide
  extend BCDD::Resultable
  extend self

  def call(arg1, arg2)
    validate_numbers(arg1, arg2)
      .and_then(:validate_non_zero)
      .and_then(:divide)
  end

  private

  def validate_numbers(arg1, arg2)
    arg1.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg2 must be numeric')

    Success(:ok, [arg1, arg2])
  end

  def validate_non_zero(numbers)
    return Success(:ok, numbers) unless numbers.last.zero?

    Failure(:division_by_zero, 'arg2 must not be zero')
  end

  def divide((number1, number2))
    Success(:division_completed, number1 / number2)
  end
end
```

- Make the `BCDD::Result#initialize` enabled to receive a subject.

- Make the `BCDD::Result#and_then` method receive a method name (symbol) and perform it on the result subject (added by `BCDD::Resultable`). The called method must return a result; otherwise, an error (`BCDD::Result::Error::UnexpectedOutcome`) will be raised.

- Add `BCDD::Result::Error::UnexpectedOutcome` to represent an unexpected outcome.

- Add `BCDD::Result::Error::WrongResultSubject` to represent a wrong result subject. When using `BCDD::Resultable`, the result subject must be the same as the target object.

- Add `BCDD::Result::Error::WrongSubjectMethodArity` to represent a wrong subject method arity. Valid arities are 0 and 1.

### Removed

- **(BREAKING)** Remove `BCDD::Result::Error::UnexpectedBlockOutcome`. It was replaced by `BCDD::Result::Error::UnexpectedOutcome`.

## [0.1.0] - 2023-09-25

### Added

- Add `BCDD::Result` to represent a result.

- Add `BCDD::Result#type` to get the result type. The type must be a symbol.

- Add `BCDD::Result#value` to get the result value. The value can be anything.

- Add `BCDD::Result#success?` to check if the result is a success. You can also check the result type by passing an argument to it. For example, `result.success?(:ok)` will check if the result is a success and if the type is `:ok`.

- Add `BCDD::Result#failure?` to check if the result is a failure. You can also check the result type by passing an argument to it. For example, `result.failure?(:error)` will check if the result is a failure and if the type is `:error`.

- Add `BCDD::Result#value_or` to get the value of a successful result or a default value (from the block) if it is a failure.

- Add `BCDD::Result#==` to compare two results.

- Add `BCDD::Result#eql?` to compare two results.

- Add `BCDD::Result#hash` to get the hash of a result.

- Add `BCDD::Result#inspect` to get the string representation of a result.

- Add `BCDD::Result#on` to execute a block depending on the result type (independently of the result being a success or a failure). The block will receive the result value as an argument, and the result itself will be returned after (or not) the block execution. The method can be called multiple times and with one or more arguments. For example, `result.on(:ok, :error) { |value| # ... }` will execute the block if the result type is `:ok` or `:error`.

- Add `BCDD::Result#on_success` to execute a block if the result is a success. It works like `BCDD::Result#on` but only for success results.

- Add `BCDD::Result#on_failure` to execute a block if the result is a failure. It works like `BCDD::Result#on` but only for failure results.

- Add `BCDD::Result#and_then` to execute the block if the result is a success. You can use it to chain multiple operations. If the block returns a failure result and there are other `and_then` calls after it, the next blocks will be skipped.

- Add `BCDD::Result#data` as an alias for `BCDD::Result#value`.

- Add `BCDD::Result#data_or` as an alias for `BCDD::Result#value_or`.

- Add `BCDD::Result#on_type` as an alias for `BCDD::Result#on`.

- Add `BCDD::Result::Success()` to factory a success result.

- Add `BCDD::Result::Failure()` to factory a failure result.
