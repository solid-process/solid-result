- [\[Unreleased\]](#unreleased)
  - [Added](#added)
  - [Changed](#changed)
  - [Removed](#removed)
- [\[0.7.0\] - 2023-10-27](#070---2023-10-27)
  - [Added](#added-1)
  - [Changed](#changed-1)
- [\[0.6.0\] - 2023-10-11](#060---2023-10-11)
  - [Added](#added-2)
  - [Changed](#changed-2)
- [\[0.5.0\] - 2023-10-09](#050---2023-10-09)
  - [Added](#added-3)
- [\[0.4.0\] - 2023-09-28](#040---2023-09-28)
  - [Added](#added-4)
  - [Changed](#changed-3)
  - [Removed](#removed-1)
- [\[0.3.0\] - 2023-09-26](#030---2023-09-26)
  - [Added](#added-5)
- [\[0.2.0\] - 2023-09-26](#020---2023-09-26)
  - [Added](#added-6)
  - [Removed](#removed-2)
- [\[0.1.0\] - 2023-09-25](#010---2023-09-25)
  - [Added](#added-7)

## [Unreleased]

### Added

- Add `BCDD::Result.config`
  - **Feature**
    ```ruby
    BCDD::Result.config.feature.options
    BCDD::Result.config.feature.enabled?(:expectations)
    BCDD::Result.config.feature.enable!(:expectations)
    BCDD::Result.config.feature.disable!(:expectations)
    ```
  - **Default Add-ons**
    ```ruby
    BCDD::Result.config.addon.options
    BCDD::Result.config.addon.enabled?(:continue)
    BCDD::Result.config.addon.enable!(:continue)
    BCDD::Result.config.addon.disable!(:continue)
    ```
  - **Pattern matching**
    ```ruby
    BCDD::Result.config.pattern_matching.options
    BCDD::Result.config.pattern_matching.enabled?(:nil_as_valid_value_checking)
    BCDD::Result.config.pattern_matching.enable!(:nil_as_valid_value_checking)
    BCDD::Result.config.pattern_matching.disable!(:nil_as_valid_value_checking)
    ```
  - **Constant Aliases**
    ```ruby
    BCDD::Result.config.constant_alias.options
    BCDD::Result.config.constant_alias.enabled?('Result')
    BCDD::Result.config.constant_alias.enable!('Result')
    BCDD::Result.config.constant_alias.disable!('Result')
    ```

- Add `BCDD::Result::configuration`. It freezes the configuration, disallowing methods that promote changes but allowing the query ones. You can use this feature to ensure integrity in your configuration.
  ```ruby
  BCDD::Result.configuration do |config|
    config.addon.enable!(:continue)

    config.constant_alias.enable!('Result')

    config.pattern_matching.disable!(:nil_as_valid_value_checking)

    config.feature.disable!(:expectations) if ::Rails.env.production?
  end

  BCDD::Result.config.addon.enabled?(:continue)         # true
  BCDD::Result.config.constant_alias.enabled?('Result') # true

  BCDD::Result.config.addon.disable!(:continue)         # raises FrozenError
  BCDD::Result.config.constant_alias.disable!('Result') # raises FrozenError
  ```

- Allow the pattern matching feature to be turned on/off through the `BCDD::Result::Expectations.mixin`. Now, it can be used without enabling it for the whole project.
  ```ruby
  extend BCDD::Result::Expectations.mixin(
    config: {
      addon:            { continue: false },
      pattern_matching: { nil_as_valid_value_checking: true },
    },
    success: {
      numbers: ->(value) { value => [Numeric, Numeric] },
      division_completed: Numeric
    },
    failure: {
      invalid_arg: String,
      division_by_zero: String
    }
  )
  ```

### Changed

- **(BREAKING)** Replace `BCDD::Result::Contract.nil_as_valid_value_checking!` with `BCDD::Result::Config.pattern_matching.enable!(:nil_as_valid_value_checking)`.

- **(BREAKING)** Replace `BCDD::Result::Contract.nil_as_valid_value_checking?` with `BCDD::Result::Config.pattern_matching.enabled?(:nil_as_valid_value_checking)`.

- **(BREAKING)** Replace `mixin(with:)` with `mixin(config:)` keyword argument.

- **(BREAKING)** Change the addons definition.
  - **From**
  ```ruby
  BCDD::Result.mixin(with: :Continue)
  BCDD::Result.mixin(with: [:Continue])
  ```
  - **To**
  ```ruby
  BCDD::Result.mixin(config: { addon: { continue: true } })
  ```
  - These examples are valid to all kinds of mixins (`BCDD::Result.mixin`, `BCDD::Result::Context.mixin`, `BCDD::Result::Expectations.mixin`, `BCDD::Result::Context::Expectations.mixin`)

### Removed

- **(BREAKING)** Remove the `lib/result` file. Now you can define `Result` as an alias for `BCDD::Result` using `BCDD::Result::Config.constant_alias.enable!('Result')`.

## [0.7.0] - 2023-10-27

### Added

- Add `BCDD::Result::Context`. It is a `BCDD::Result`, meaning it has all the features of the `BCDD::Result`. The main difference is that it only accepts keyword arguments as a value, which applies to the `and_then`: The called methods must receive keyword arguments, and the dependency injection will be performed through keyword arguments.<br/><br/>
As the input/output are hashes, the results of each `and_then` call will automatically accumulate. This is useful in operations chaining, as the result of the previous operations will be automatically available for the next one. Because of this behavior, the `BCDD::Result::Context` has the `#and_expose` method to expose only the desired keys from the accumulated result.

- Add `BCDD::Result::Context::Expectations.new` and `BCDD::Result::Context::Expectations.mixin`. Both are similar to `BCDD::Result::Expectations.new` and `BCDD::Result::Expectations.mixin`, but they are for `BCDD::Result::Context` instead of `BCDD::Result`.
  - The `BCDD::Result::Context.mixin` and `BCDD::Result::Context::Expectations.mixin` support the `with: :Continue` option.

- Enhance Pattern Matching support. When a `NoMatchingPatternError` occurs inside a value checking, the `BCDD::Result::Contract::Error::UnexpectedValue` message will include the value and the expected patterns.

- Add `BCDD::Result::Success::Methods` to be share common methods between `BCDD::Result::Success` and `BCDD::Result::Context::Success`.

- Add `BCDD::Result::Failure::Methods` to be share common methods between `BCDD::Failure::Success` and `BCDD::Result::Context::Failure`.

- Make all mixin generators produce a named module. The module name will be added to the target class/module (who included/extended a `BCDD::Result`/`BCDD::Result::Context` mixin module).

- Add `BCDD::Result::Contract.nil_as_valid_value_checking!`. Please use this method when using the one-line pattern-matching operators on the result's value expectations.

### Changed

- **(BREAKING)** Rename `BCDD::Result::WrongResultSubject` to `BCDD::Result::Error::InvalidResultSubject`.
- **(BREAKING)** Rename `BCDD::Result::WrongSubjectMethodArity` to `BCDD::Result::Error::InvalidSubjectMethodArity`.
- **(BREAKING)** Rename the constant produced by `BCDD::Result::Expectations.mixins` from `Expected` to `Result`.
- Extract the major part of the `BCDD::Result::Expectations` components/features to `BCDD::Result::Contract`.
  - **(BREAKING)** `BCDD::Result::Expectations::Error` became `BCDD::Result::Contract::Error`. So, `BCDD::Result::Expectations::Error::UnexpectedType` and `BCDD::Result::Expectations::Error::UnexpectedValue` are now `BCDD::Result::Contract::Error::UnexpectedType` and `BCDD::Result::Contract::Error::UnexpectedValue`.

## [0.6.0] - 2023-10-11

### Added

- Add `BCDD::Result.mixin` to be included or extended in any object. It will add `Success()` and `Failure()` to the target object (the object who receives the include/extend).

- Add `BCDD::Result.mixin(with: :Continue)`. This addon will add a `Continue(value)` method to the target object to produce a `Success(:continued, value)` result.

- Add `BCDD::Result::Expectations.mixin(with: :Continue)`, it is similar to `BCDD::Result.mixin(with: :Continue)`, the key difference is that the `Continue(value)` will be ignored by the expectations. This is extremely useful when you want to use `Continue(value)` to chain operations, but you don't want to declare N success types in the expectations.

- Increase the arity of `BCDD::Result#and_then`. Now, it can receive a second argument (a value to be injected and shared with the subject's method).

- Increase the arity (maximum of 2) for the methods called through `BCDD::Result#and_then`. The second argument is the value injected by `BCDD::Result#and_then`.

### Changed

- **(BREAKING)** Make `BCDD::Result::Mixin` be a private constant. The `BCDD::Result.mixin` method is the new way to use it.

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
  extend self, BCDD::Resultable

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
