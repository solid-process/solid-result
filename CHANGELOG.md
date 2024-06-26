- [\[Unreleased\]](#unreleased)
- [2.0.0 - 2024-04-13](#200---2024-04-13)
  - [Changed](#changed)
- [1.1.0 - 2024-03-25](#110---2024-03-25)
  - [Added](#added)
- [1.0.0 - 2024-03-16](#100---2024-03-16)
  - [Added](#added-1)
  - [Changed](#changed-1)
- [\[0.13.0\] - 2024-02-01](#0130---2024-02-01)
  - [Added](#added-2)
  - [Changed](#changed-2)
- [\[0.12.0\] - 2024-01-07](#0120---2024-01-07)
  - [Added](#added-3)
  - [Changed](#changed-3)
- [\[0.11.0\] - 2024-01-02](#0110---2024-01-02)
  - [Added](#added-4)
  - [Changed](#changed-4)
- [\[0.10.0\] - 2023-12-31](#0100---2023-12-31)
  - [Added](#added-5)
- [\[0.9.1\] - 2023-12-12](#091---2023-12-12)
  - [Changed](#changed-5)
  - [Fixed](#fixed)
- [\[0.9.0\] - 2023-12-12](#090---2023-12-12)
  - [Added](#added-6)
  - [Changed](#changed-6)
- [\[0.8.0\] - 2023-12-11](#080---2023-12-11)
  - [Added](#added-7)
  - [Changed](#changed-7)
  - [Removed](#removed)
- [\[0.7.0\] - 2023-10-27](#070---2023-10-27)
  - [Added](#added-8)
  - [Changed](#changed-8)
- [\[0.6.0\] - 2023-10-11](#060---2023-10-11)
  - [Added](#added-9)
  - [Changed](#changed-9)
- [\[0.5.0\] - 2023-10-09](#050---2023-10-09)
  - [Added](#added-10)
- [\[0.4.0\] - 2023-09-28](#040---2023-09-28)
  - [Added](#added-11)
  - [Changed](#changed-10)
  - [Removed](#removed-1)
- [\[0.3.0\] - 2023-09-26](#030---2023-09-26)
  - [Added](#added-12)
- [\[0.2.0\] - 2023-09-26](#020---2023-09-26)
  - [Added](#added-13)
  - [Removed](#removed-2)
- [\[0.1.0\] - 2023-09-25](#010---2023-09-25)
  - [Added](#added-14)

## [Unreleased]

## 2.0.0 - 2024-04-13

### Changed

- **(BREAKING)** Rebrand the gem from `bcdd-result` to `Solid::Result`.
  - `Solid::Result` replaces `BCDD::Result`.
  - `Solid::Output` replaces `BCDD::Context`.

## 1.1.0 - 2024-03-25

### Added

- Add some Hash's methods to `BCDD::Context`. They are:
  - `#slice` to extract only the desired keys.
  - `#[]`, `#dig`, `#fetch` to access the values.
  - `#values_at` and `#fetch_values` to get the values of the desired keys.

## 1.0.0 - 2024-03-16

### Added

- Add the `BCDD::Success` and `BCDD::Failure` modules. They are key to checking whether a result is a success or a failure independently of whether it is a `BCDD::Result` or a `BCDD::Context`.
- Add `BCDD::Result#type?` to check if the given type is the result type.
- Add `BCDD::Result#is?` as an alias for `BCDD::Result#type?`.
- Add `BCDD::Result#method_missing` to allow the type checking through method calls. For example, `result.ok?` will check if the result type is `:ok`.

> Note: All the methods above are available for the `BCDD::Context` as well.

### Changed

- **(BREAKING)** Replace transitions with event_logs concept.
  - The `BCDD::Result::Transitions` module was renamed to `BCDD::Result::EventLogs`
  - The `BCDD::Result.transitions` to `BCDD::Result.event_logs`.

- **(BREAKING)** Change `BCDD::Result#deconstruct_keys` to return a hash with the keys `:type` and `:value` when one of these keys is present. Otherwise, it will return the value itself.

- **(BREAKING)** Replace trasitions metadata `:ids_tree`, and `:ids_matrix` with `:ids` property. This property is a hash with the following keys:
  - `:tree`, a graph/tree representation of the transitions ids.
  - `:level_parent`, a hash with the level (depth) of each transition and its parent id.
  - `:matrix`, a matrix representation of the transitions ids. It is a simplification of the `:tree` property.

- Transform `BCDD::Result::Context` into `BCDD::Context`. But a constant alias was added to keep the old name. You can use `BCDD::Result::Context` or `BCDD::Context` to access the same class.

## [0.13.0] - 2024-02-01

### Added

- `BCDD::Result::Context#and_expose` - Raise error when trying to expose an invalid key.

- `BCDD::Result.configuration` - Accept freeze option (default: `true`). When true, the configuration will be frozen after the block execution.

- `BCDD::Result.config.transitions` - Add transitions feature configuration.
  - `config.transitions.listener =` - Set a listener to be called during the result transitions tracking. It must be a class that includes `BCDD::Result::Transitions::Listener`.
  - `config.transitions.trace_id =` - Set a lambda (must have arity 0) to be called to get a trace id. Use to correlate different or the same operation (executed multiple times).

- Add transitions metadata property `:ids_matrix`. It is a simplification of the `:ids_tree` property. The matrix rows are the direct transitions from the root transition block, and the columns are the transitions nested from the direct transitions.
  ```ruby
  # ids_matrix       # {
  0 | 1 | 2 | 3 | 4  #   0 => [0, 0],
  - | - | - | - | -  #   1 => [1, 1],
  0 |   |   |   |    #   2 => [1, 2],
  1 | 1 | 2 |   |    #   3 => [2, 1],
  2 | 3 |   |   |    #   4 => [3, 1],
  3 | 4 | 5 | 6 | 7  #   5 => [3, 2],
  4 | 8 |   |   |    #   6 => [3, 3],
                     #   7 => [3, 4],
                     #   8 => [4, 1]
                     # }
  ```

- Add `BCDD::Result::Transitions::Listeners[]` - It creates a listener of listeners, which will be called in the order they were added.

### Changed

- **(BREAKING)** Rename `Given()` type from `:given` to `:_given_`.

- **(BREAKING)** Rename `Continue()` type from `:continued` to `:_continue_`.

- **(BREAKING)** Move transition `:source` from `:and_then` to `:result` property.

- **(BREAKING)** Rename transitions metadata property `:tree_map` to `:ids_tree`.
  ```ruby
  # ids_tree #
  0          # [0, [
  |- 1       #   [1, [[2, []]]],
  |  |- 2    #   [3, []],
  |- 3       #   [4, [
  |- 4       #     [5, []],
  |  |- 5    #     [6, [[7, []]]]
  |  |- 6    #   ]],
  |     |- 7 #   [8, []]
  |- 8       # ]]
  ```

## [0.12.0] - 2024-01-07

### Added

- Add `BCDD::Result#and_then!` and `BCDD::Result::Context#and_then!` to execute a callable object (any object that responds to `#call`) to produce a result. The main difference between the `#and_then` and `#and_then!` is that the latter does not check the result source.
  - **Attention:** to ensure the correct behavior, do not mix `#and_then` and `#and_then!` in the same result chain.
  - This feature is turned off by default. You can enable it through the `BCDD::Result.config.feature.enable!(:and_then!)`.
  - The method called by default (`:call`) can be changed through `BCDD::Result.config.and_then!.default_method_name_to_call=`.

### Changed

- **(BREAKING)** Renames the subject concept/term to `source`. When a mixin is included/extended, it defines the `Success()` and `Failure()` methods. Since the results are generated in a context (instance or singleton where the mixin was used), they will have a defined source (instance or singleton itself).
  > Definition of source
  >
  > From dictionary:
  > * a place, person, or thing from which something comes or can be obtained.

## [0.11.0] - 2024-01-02

### Added

- Add the `Given()` addon to produce a `Success(:given, value)` result. As the `Continue()` addon, it is ignored by the expectations. Use it to add a value to the result chain and invoke the next step (through `and_then`).

### Changed

- **(BREAKING)** Rename halted concept to terminal. Failures are terminal by default, but you can make a success terminal by enabling the `:continue` addon.
  > Definition of terminal
  >
  > From dictionary:
  > * of, forming, or situated at the end or extremity of something.
  > * the end of a railroad or other transport route, or a station at such a point.
  >
  > From Wikipedia:
  > * A "terminus" or "terminal" is a station at the end of a railway line.

- **(BREAKING)** Rename `BCDD::Result::Context::Success#and_expose` halted keyword argument to `terminal`.

- **(BREAKING)** Rename `BCDD::Result#halted?` to `BCDD::Result#terminal?`.

## [0.10.0] - 2023-12-31

### Added

- Add `BCDD::Result.transitions(&block)` to track all transitions in the same or between different operations. When there is a nesting of transition blocks, this mechanism will be able to correlate parent and child blocks and present the duration of all operations in milliseconds.

- Add `BCDD::Result.config.feature.disable!(:transitions)` and `BCDD::Result.config.feature.enable!(:transitions)` to turn on/off the `BCDD::Result.transitions` feature.

## [0.9.1] - 2023-12-12

### Changed

- **(BREAKING)** Make `BCDD::Result::Context::Success#and_expose()` to produce a terminal success by default. You can turn this off by passing `halted: false`.

### Fixed

- Make `BCDD::Result::Context#and_then(&block)` accumulate the result value.

## [0.9.0] - 2023-12-12

### Added

- Add new `BCDD::Result.config.constant_alias` options. `Context` and `BCDD::Context` are now available as aliases for `BCDD::Result::Context`.
  ```ruby
  BCDD::Result.config.constant_alias.enable!('Context')

  BCDD::Result.config.constant_alias.enable!('BCDD::Context')
  ```

- Add `BCDD::Result#halted?` to check if the result is halted. Failure results are halted by default, but you can halt a successful result by enabling the `:continue` addon.

### Changed

- **(BREAKING)** Change the `:continue` addon to halt the step chain on the first `Success()` result. So, if you want to advance to the next step, you must use `Continue(value)` instead of `Success(type, value)`. Otherwise, the step chain will be halted. (Implementation of the following proposal: https://github.com/B-CDD/result/issues/14)

- **(BREAKING)** Rename `BCDD::Result::Data#name` to `BCDD::Result::Data#kind`. The new word is more appropriate as it represents a result's kind (success or failure).

## [0.8.0] - 2023-12-11

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
