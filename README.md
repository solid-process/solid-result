<p align="center">
  <h1 align="center" id="-bcddresult">🔀 BCDD::Result</h1>
  <p align="center"><i>Empower Ruby apps with a pragmatic use of Railway Oriented Programming.</i></p>
  <p align="center">
    <img src="https://img.shields.io/badge/ruby->%3D%202.7.0-ruby.svg?colorA=99004d&colorB=cc0066" alt="Ruby">
    <a href="https://rubygems.org/gems/bcdd-result"><img src="https://badge.fury.io/rb/bcdd-result.svg" alt="bcdd-result gem version" height="18"></a>
  </p>
</p>

It's a general-purpose result monad that allows you to create objects representing a success (`BCDD::Result::Success`) or failure (`BCDD::Result::Failure`).

**What problem does it solve?**

It allows you to consistently represent the concept of success and failure throughout your codebase.

Furthermore, this abstraction exposes several features that will be useful to make the application flow react cleanly and securely to the result represented by these objects.

Use it to enable the [Railway Oriented Programming](https://fsharpforfunandprofit.com/rop/) pattern (superpower) in your code.

- [Ruby Version](#ruby-version)
- [Installation](#installation)
- [Usage](#usage)
    - [`BCDD::Result` *versus* `Result`](#bcddresult-versus-result)
- [Reference](#reference)
  - [Result Attributes](#result-attributes)
    - [Receiving types in `result.success?` or `result.failure?`](#receiving-types-in-resultsuccess-or-resultfailure)
  - [Result Hooks](#result-hooks)
    - [`result.on`](#resulton)
    - [`result.on_type`](#resulton_type)
    - [`result.on_success`](#resulton_success)
    - [`result.on_failure`](#resulton_failure)
    - [`result.on_unknown`](#resulton_unknown)
    - [`result.handle`](#resulthandle)
  - [Result Value](#result-value)
    - [`result.value_or`](#resultvalue_or)
  - [Result Data](#result-data)
    - [`result.data`](#resultdata)
  - [Railway Oriented Programming](#railway-oriented-programming)
    - [`result.and_then`](#resultand_then)
    - [`BCDD::Result::Mixin`](#bcddresultmixin)
      - [Class example (Instance Methods)](#class-example-instance-methods)
      - [Module example (Singleton Methods)](#module-example-singleton-methods)
      - [Restrictions](#restrictions)
  - [Pattern Matching](#pattern-matching)
    - [`Array`/`Find` patterns](#arrayfind-patterns)
    - [`Hash` patterns](#hash-patterns)
    - [BCDD::Result::Expectations](#bcddresultexpectations)
  - [`BCDD::Result::Expectations`](#bcddresultexpectations-1)
    - [Standalone *versus* Mixin mode](#standalone-versus-mixin-mode)
    - [Type checking - Result Hooks](#type-checking---result-hooks)
      - [`#success?` and `#failure?`](#success-and-failure)
      - [`#on` and `#on_type`](#on-and-on_type)
      - [`#on_success` and `#on_failure`](#on_success-and-on_failure)
      - [`#handle`](#handle)
    - [Type checking - Result Creation](#type-checking---result-creation)
      - [Mixin mode](#mixin-mode)
      - [Standalone mode](#standalone-mode)
    - [Value checking - Result Creation](#value-checking---result-creation)
      - [Success()](#success)
      - [Failure()](#failure)
- [About](#about)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)

## Ruby Version

`>= 2.7.0`

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bcdd-result', require: 'bcdd/result'
```

And then execute:

    $ bundle install

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install bcdd-result

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

## Usage

To create a result, you must define a type (symbol) and its value (any kind of object). e.g.,

```ruby
BCDD::Result::Success(:ok, :1)           #
                                         # The value can be any kind of object
BCDD::Result::Failure(:err, 'the value') #
```

The reason for defining a `type` is that it is very common for a method/operation to return different types of successes or failures. Because of this, the `type` will always be required. e,g.,

```ruby
BCDD::Result::Success(:ok)  #
                            # The type is mandatory and the value is optional
BCDD::Result::Failure(:err) #
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### `BCDD::Result` *versus* `Result`

The `BCDD::Result` is the main module of this gem. It contains all the features, constants, and methods you will use to create and manipulate results.

The `Result` is an alias of `BCDD::Result`. It was created to facilitate the use of this gem in the code. So, instead of requiring `BCDD::Result` everywhere, you can require `Result` and use it as an alias.

```ruby
require 'result'

Result::Success(:ok) # <BCDD::Result::Success type=:ok value=nil>
```

All the examples in this README that use `BCDD::Result` can also be used with `Result`.

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

## Reference

### Result Attributes

Both `BCDD::Result::Success` and `BCDD::Result::Failure` are composed of the same methods. Look at the basic ones:

**BCDD::Result::Success**

```ruby
################
# With a value #
################
result = BCDD::Result::Success(:ok, my: 'value')

result.success? # true
result.failure? # false
result.type     # :ok
result.value    # {:my => "value"}

###################
# Without a value #
###################
result = BCDD::Result::Success(:yes)

result.success? # true
result.failure? # false
result.type     # :yes
result.value    # nil
```

**BCDD::Result::Failure**

```ruby
################
# With a value #
################
result = BCDD::Result::Failure(:err, my: 'value')

result.success? # false
result.failure? # true
result.type     # :err
result.value    # {:my => "value"}

###################
# Without a value #
###################
result = BCDD::Result::Failure(:no)

result.success? # false
result.failure? # true
result.type     # :no
result.value    # nil
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### Receiving types in `result.success?` or `result.failure?`

`BCDD::Result#success?` and `BCDD::Result#failure?` are methods that allow you to check if the result is a success or a failure.

You can also check the result type by passing an argument to it. For example, `result.success?(:ok)` will check if the result is a success and if the type is `:ok`.

```ruby
result = BCDD::Result::Success(:ok)

result.success?        # true
result.success?(:ok)   # true
result.success?(:okay) # false
```

The same is valid for `BCDD::Result#failure?`.

```ruby
result = BCDD::Result::Failure(:err)

result.failure?         # true
result.failure?(:err)   # true
result.failure?(:error) # false
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

### Result Hooks

Result hooks are methods that allow you to perform a block of code depending on the result type.

To exemplify the them, I will implement a method that knows how to divide two numbers.

```ruby
def divide(arg1, arg2)
  arg1.is_a?(::Numeric) or return BCDD::Result::Failure(:invalid_arg, 'arg1 must be numeric')
  arg2.is_a?(::Numeric) or return BCDD::Result::Failure(:invalid_arg, 'arg2 must be numeric')

  return BCDD::Result::Failure(:division_by_zero, 'arg2 must not be zero') if arg2.zero?

  BCDD::Result::Success(:division_completed, arg1 / arg2)
end
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### `result.on`

`BCDD::Result#on` will perform the block when the type matches the result type.

Regardless of the block being executed, the return of the method will always be the result itself.

The result value will be exposed as the first argument of the block.

```ruby
result = divide(nil, 2)

output =
  result
    .on(:invalid_arg) { |msg| puts msg }
    .on(:division_by_zero) { |msg| puts msg }
    .on(:division_completed) { |number| puts number }

# The code above will print 'arg1 must be numeric' and return the result itself.

result.object_id == output.object_id # true
```

You can define multiple types to be handled by the same hook/block
```ruby
result = divide(4, 0)

output =
  result.on(:invalid_arg, :division_by_zero, :division_completed) { |value| puts value }

# The code above will print 'arg2 must not be zero' and return the result itself.

result.object_id == output.object_id # true
```

*PS: The `divide()` implementation is [here](#result-hooks).*

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### `result.on_type`

`BCDD::Result#on_type` is an alias of `BCDD::Result#on`.

#### `result.on_success`

`BCDD::Result#on_success` is very similar to the `BCDD::Result#on` hook. The main differences are:

1. Only perform the block when the result is a success.
2. If the type is missing it will perform the block for any success.

```ruby
# It performs the block and return itself.

divide(4, 2).on_success { |number| puts number }

divide(4, 2).on_success(:division_completed) { |number| puts number }

# It doesn't perform the block, but return itself.

divide(4, 4).on_success(:ok) { |value| puts value }

divide(4, 4).on_failure { |error| puts error }
```

*PS: The `divide()` implementation is [here](#result-hooks).*

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### `result.on_failure`

Is the opposite of `Result#on_success`.

```ruby
# It performs the block and return itself.

divide(nil, 2).on_failure { |error| puts error }

divide(4, 0).on_failure(:invalid_arg, :division_by_zero) { |error| puts error }

# It doesn't perform the block, but return itself.

divide(4, 0).on_success { |number| puts number }

divide(4, 0).on_failure(:invalid_arg) { |error| puts error }
```

*PS: The `divide()` implementation is [here](#result-hooks).*

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### `result.on_unknown`

`BCDD::Result#on_unknown` will perform the block when no other hook (`#on`, `#on_type`, `#on_failure`, `#on_success`) has been executed.

Regardless of the block being executed, the return of the method will always be the result itself.

The result value will be exposed as the first argument of the block.

```ruby
divide(4, 2)
  .on(:invalid_arg) { |msg| puts msg }
  .on(:division_by_zero) { |msg| puts msg }
  .on_unknown { |value, type| puts [type, value].inspect }

# The code above will print '[:division_completed, 2]' and return the result itself.
```

*PS: The `divide()` implementation is [here](#result-hooks).*

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### `result.handle`

This method will allow you to define blocks for each hook (type, failure, success), but instead of returning itself, it will return the output of the first match/block execution.

```ruby
divide(4, 2).handle do |result|
  result.success { |number| number }
  result.failure(:invalid_arg) { |err| puts err }
  result.type(:division_by_zero) { raise ZeroDivisionError }
  result.unknown { raise NotImplementedError }
end

#or

divide(4, 2).handle do |on|
  on.success { |number| number }
  on.failure { |err| puts err }
  on.unknown { raise NotImplementedError }
end

#or

divide(4, 2).handle do |on|
  on.type(:invalid_arg) { |err| puts err }
  on.type(:division_by_zero) { raise ZeroDivisionError }
  on.type(:division_completed) { |number| number }
  on.unknown { raise NotImplementedError }
end

# or

divide(4, 2).handle do |on|
  on[:invalid_arg] { |err| puts err }
  on[:division_by_zero] { raise ZeroDivisionError }
  on[:division_completed] { |number| number }
  on.unknown { raise NotImplementedError }
end

# The [] syntax 👆 is an alias of #type.
```

**Notes:**
* You can define multiple types to be handled by the same hook/block
* If the type is missing, it will perform the block for any success or failure handler.
* The `#type` and `#[]` handlers will require at least one type/argument.

*PS: The `divide()` implementation is [here](#result-hooks).*

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

### Result Value

The most simple way to get the result value is by calling `BCDD::Result#value`.

But sometimes you need to get the value of a successful result or a default value if it is a failure. In this case, you can use `BCDD::Result#value_or`.

#### `result.value_or`

`BCCD::Result#value_or` returns the value when the result is a success, but if is a failure the block will be performed, and its outcome will be the output.

```ruby
def divide(arg1, arg2)
  arg1.is_a?(::Numeric) or return BCDD::Result::Failure(:invalid_arg)
  arg2.is_a?(::Numeric) or return BCDD::Result::Failure(:invalid_arg)

  return BCDD::Result::Failure(:division_by_zero) if arg2.zero?

  BCDD::Result::Success(:division_completed, arg1 / arg2)
end

# When the result is success
divide(4, 2).value_or { 0 } # 2

# When the result is failure
divide('4', 2).value_or { 0 } # 0
divide(4, '2').value_or { 0 } # 0
divide(100, 0).value_or { 0 } # 0
```

*PS: The `divide()` implementation is [here](#result-hooks).*

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

### Result Data

#### `result.data`

The `BCDD::Result#data` exposes the result attributes (name, type, value) directly and as a hash (`to_h`/`to_hash`) and array (`to_a`/`to_ary`).

This is helpful if you need to access the result attributes generically or want to use Ruby features like splat (`*`) and double splat (`**`) operators.

See the examples below to understand how to use it.

```ruby
result = BCDD::Result::Success(:ok, 1)

success_data = result.data # #<BCDD::Result::Data name=:success type=:ok value=1>

success_data.name  # :success
success_data.type  # :ok
success_data.value # 1

success_data.to_h  # {:name=>:success, :type=>:ok, :value=>1}
success_data.to_a  # [:success, :ok, 1]

name, type, value = success_data

[name, type, value] # [:success, :ok, 1]

def print_to_ary(name, type, value)
  puts [name, type, value].inspect
end

def print_to_hash(name:, type:, value:)
  puts [name, type, value].inspect
end

print_to_ary(*success_data)   # [:success, :ok, 1]

print_to_hash(**success_data) # [:success, :ok, 1]
```

> **NOTE:** The example above uses a success result, but the same is valid for a failure result.

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

### Railway Oriented Programming

This feature/pattern is also known as ["Railway Oriented Programming"](https://fsharpforfunandprofit.com/rop/).

The idea is to chain blocks and creates a pipeline of operations that can be interrupted by a failure.

In other words, the block will be executed only if the result is a success.
So, if some block returns a failure, the following blocks will be skipped.

Due to this characteristic, you can use this feature to express some logic as a sequence of operations. And have the guarantee that the process will stop by the first failure detection, and if everything is ok, the final result will be a success.

#### `result.and_then`

```ruby
module Divide
  extend self

  def call(arg1, arg2)
    validate_numbers(arg1, arg2)
      .and_then { |numbers| validate_non_zero(numbers) }
      .and_then { |numbers| divide(numbers) }
  end

  private

  def validate_numbers(arg1, arg2)
    arg1.is_a?(::Numeric) or return BCDD::Result::Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(::Numeric) or return BCDD::Result::Failure(:invalid_arg, 'arg2 must be numeric')

    BCDD::Result::Success(:ok, [arg1, arg2])
  end

  def validate_non_zero(numbers)
    return BCDD::Result::Success(:ok, numbers) unless numbers.last.zero?

    BCDD::Result::Failure(:division_by_zero, 'arg2 must not be zero')
  end

  def divide((number1, number2))
    BCDD::Result::Success(:division_completed, number1 / number2)
  end
end
```

Example of outputs:

```ruby
Divide.call('4', 2)
#<BCDD::Result::Failure type=:invalid_arg data="arg1 must be numeric">

Divide.call(2, '2')
#<BCDD::Result::Failure type=:invalid_arg data="arg2 must be numeric">

Divide.call(2, 0)
#<BCDD::Result::Failure type=:division_by_zero data="arg2 must not be zero">

Divide.call(2, 2)
#<BCDD::Result::Success type=:division_completed data=1>
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### `BCDD::Result::Mixin`

It is a module that can be included/extended by any object. It adds two methods to the target object: `Success()` and `Failure()`. The main difference between these methods and `BCDD::Result::Success()`/`BCDD::Result::Failure()` is that the first ones will use the target object (who received the include/extend) as the result's subject.

And because of this, you can use the `#and_then` method to call methods from the result's subject.

##### Class example (Instance Methods)

```ruby
class Divide
  include BCDD::Result::Mixin

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

    # As arg1 and arg2 are instance methods, they will be available in the instance scope.
    # So, in this case, I'm passing them as an array to show how the next method can receive the value as its argument.
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

Divide.new(4, 2).call #<BCDD::Result::Success type=:division_completed value=2>

Divide.new(4, 0).call   #<BCDD::Result::Failure type=:division_by_zero value="arg2 must not be zero">
Divide.new('4', 2).call #<BCDD::Result::Failure type=:invalid_arg value="arg1 must be numeric">
Divide.new(4, '2').call #<BCDD::Result::Failure type=:invalid_arg value="arg2 must be numeric">
```

##### Module example (Singleton Methods)

```ruby
module Divide
  extend BCDD::Result::Mixin
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

Divide.call(4, 2) #<BCDD::Result::Success type=:division_completed value=2>

Divide.call(4, 0)   #<BCDD::Result::Failure type=:division_by_zero value="arg2 must not be zero">
Divide.call('4', 2) #<BCDD::Result::Failure type=:invalid_arg value="arg1 must be numeric">
Divide.call(4, '2') #<BCDD::Result::Failure type=:invalid_arg value="arg2 must be numeric">
```

##### Restrictions

The unique condition for using the `#and_then` to call methods is that they must use the `Success()` and `Failure()` to produce their results.

If you use `BCDD::Result::Subject()`/`BCDD::Result::Failure()`, or use result from another `BCDD::Result::Mixin` instance, the `#and_then` will raise an error because the subjects will be different.

> **Note**: You still can use the block syntax, but all the results must be produced by the subject's `Success()` and `Failure()` methods.

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

### Pattern Matching

The `BCDD::Result` also provides support to pattern matching.

In the further examples, I will use the `Divide` lambda to exemplify its usage.

```ruby
Divide = lambda do |arg1, arg2|
  arg1.is_a?(::Numeric) or return BCDD::Result::Failure(:invalid_arg, 'arg1 must be numeric')
  arg2.is_a?(::Numeric) or return BCDD::Result::Failure(:invalid_arg, 'arg2 must be numeric')

  return BCDD::Result::Failure(:division_by_zero, 'arg2 must not be zero') if arg2.zero?

  BCDD::Result::Success(:division_completed, arg1 / arg2)
end
```

#### `Array`/`Find` patterns

```ruby
case Divide.call(4, 2)
in BCDD::Result::Failure[:invalid_arg, msg] then puts msg
in BCDD::Result::Failure[:division_by_zero, msg] then puts msg
in BCDD::Result::Success[:division_completed, value] then puts value
end

# The code above will print: 2

case Divide.call(4, 0)
in BCDD::Result::Failure[:invalid_arg, msg] then puts msg
in BCDD::Result::Failure[:division_by_zero, msg] then puts msg
in BCDD::Result::Success[:division_completed, value] then puts value
end

# The code above will print: arg2 must not be zero
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### `Hash` patterns

```ruby
case Divide.call(10, 2)
in { failure: { invalid_arg: msg } } then puts msg
in { failure: { division_by_zero: msg } } then puts msg
in { success: { division_completed: value } } then puts value
end

# The code above will print: 5

case Divide.call('10', 2)
in { failure: { invalid_arg: msg } } then puts msg
in { failure: { division_by_zero: msg } } then puts msg
in { success: { division_completed: value } } then puts value
end

# The code above will print: arg1 must be numeric
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### BCDD::Result::Expectations

I'd like you to please read the following section to understand how to use this feature.

But if you are using Ruby >= 3.0, you can use the `in` operator to use the pattern matching to validate the result's value.

```ruby
module Divide
  extend BCDD::Result::Expectations.mixin(
    success: {
      numbers:            ->(value) { value in [Numeric, Numeric] },
      division_completed: ->(value) { value in (Integer | Float) }
    },
    failure: { invalid_arg: String, division_by_zero: String }
  )

  def self.call(arg1, arg2)
    arg1.is_a?(Numeric) or return Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(Numeric) or return Failure(:invalid_arg, 'arg2 must be numeric')

    arg2.zero? and return Failure(:division_by_zero, 'arg2 must not be zero')

    Success(:division_completed, arg1 / arg2)
  end
end
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

### `BCDD::Result::Expectations`

This feature lets you define contracts for your results' types and values. There are two ways to use it: the standalone (`BCDD::Result::Expectations.new`) and the mixin (`BCDD::Result::Expectations.mixin`) mode.

It was designed to ensure all the aspects of the result's type and value. So, an error will be raised if you try to create or handle a result with an unexpected type or value.

#### Standalone *versus* Mixin mode

The _**standalone mode**_ creates an object that knows how to produce and validate results based on the defined expectations. Look at the example below:

```ruby
module Divide
  Expected = BCDD::Result::Expectations.new(
    success: %i[numbers division_completed],
    failure: %i[invalid_arg division_by_zero]
  )

  def self.call(arg1, arg2)
    arg1.is_a?(Numeric) or return Expected::Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(Numeric) or return Expected::Failure(:invalid_arg, 'arg2 must be numeric')

    arg2.zero? and return Expected::Failure(:division_by_zero, 'arg2 must not be zero')

    Expected::Success(:division_completed, arg1 / arg2)
  end
end
```

In the code above, we define a constant `Divide::Expected`. And because of this (it is a constant), we can use it inside and outside the module.

Look what happens if you try to create a result without one of the expected types.

```ruby
Divide::Expected::Success(:ok)
# type :ok is not allowed. Allowed types: :numbers, :division_completed
# (BCDD::Result::Expectations::Error::UnexpectedType)

Divide::Expected::Failure(:err)
# type :err is not allowed. Allowed types: :invalid_arg, :division_by_zero
# (BCDD::Result::Expectations::Error::UnexpectedType)
```

The _**mixin mode**_ is similar to `BCDD::Result::Mixin`, but it also defines the expectations for the result's types and values.

```ruby
class Divide
  include BCDD::Result::Expectations.mixin(
    success: %i[numbers division_completed],
    failure: %i[invalid_arg division_by_zero]
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

This mode also defines an `Expected` constant to be used inside and outside the module.

> **PROTIP:**
> You can use the `Expected` constant to mock the result's type and value in your tests. As they will have the exact expectations, your tests will check if the result clients are handling the result correctly.

Now that you know the two modes, let's understand how expectations can be beneficial and powerful for defining contracts.

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### Type checking - Result Hooks

The `BCDD::Result::Expectations` will check if the result's type is valid. This checking will be performed in all the methods that rely on the result's type, like `#success?`, `#failure?`, `#on`, `#on_type`, `#on_success`, `#on_failure`, `#handle`.

##### `#success?` and `#failure?`

When you check whether a result is a success or failure, `BCDD::Result::Expectations` will check whether the result type is valid/expected. Otherwise, an error will be raised.

**Success example:**

```ruby
result = Divide.new.call(10, 2)

result.success?                      # true
result.success?(:numbers)            # false
result.success?(:division_completed) # true

result.success?(:ok)
# type :ok is not allowed. Allowed types: :numbers, :division_completed
# (BCDD::Result::Expectations::Error::UnexpectedType)
```

**Failure example:**

```ruby
result = Divide.new.call(10, '2')

result.failure?                    # true
result.failure?(:invalid_arg)      # true
result.failure?(:division_by_zero) # false

result.failure?(:err)
# type :err is not allowed. Allowed types: :invalid_arg, :division_by_zero
# (BCDD::Result::Expectations::Error::UnexpectedType)
```

*PS: The `Divide` implementation is [here](#standalone-versus-mixin-mode).*

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

##### `#on` and `#on_type`

If you use `#on` or `#on_type` to perform a block, `BCDD::Result::Expectations` will check whether the result type is valid/expected. Otherwise, an error will be raised.

```ruby
result = Divide.new.call(10, 2)

result
  .on(:invalid_arg, :division_by_zero) { |msg| puts msg }
  .on(:division_completed) { |number| puts "The result is #{number}" }

# The code above will print 'The result is 5'

result.on(:number) { |_| :this_type_does_not_exist }
# type :number is not allowed. Allowed types: :numbers, :division_completed, :invalid_arg, :division_by_zero
# (BCDD::Result::Expectations::Error::UnexpectedType)
```

*PS: The `Divide` implementation is [here](#standalone-versus-mixin-mode).*

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

##### `#on_success` and `#on_failure`

If you use `#on_success` or `#on_failure` to perform a block, `BCDD::Result::Expectations` will check whether the result type is valid/expected. Otherwise, an error will be raised.

```ruby
result = Divide.new.call(10, '2')

result
  .on_failure(:invalid_arg, :division_by_zero) { |msg| puts msg }
  .on_success(:division_completed) { |number| puts "The result is #{number}" }

result
  .on_success { |number| puts "The result is #{number}" }
  .on_failure { |msg| puts msg }

# Both codes above will print 'arg2 must be numeric'

result.on_success(:ok) { |_| :this_type_does_not_exist }
# type :ok is not allowed. Allowed types: :numbers, :division_completed
# (BCDD::Result::Expectations::Error::UnexpectedType)

result.on_failure(:err) { |_| :this_type_does_not_exist }
# type :err is not allowed. Allowed types: :invalid_arg, :division_by_zero
# (BCDD::Result::Expectations::Error::UnexpectedType)
```

*PS: The `Divide` implementation is [here](#standalone-versus-mixin-mode).*

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

##### `#handle`

The `BCDD::Result::Expectations` will also be applied on all the handlers defined by the `#handle` method/block.

```ruby
result = Divide.call(10, 2)

result.handle do |on|
  on.type(:ok) { |_| :this_type_does_not_exist }
end
# type :ok is not allowed. Allowed types: :numbers, :division_completed, :invalid_arg, :division_by_zero (BCDD::Result::Expectations::Error::UnexpectedType)

result.handle do |on|
  on.success(:ok) { |_| :this_type_does_not_exist }
end
# type :ok is not allowed. Allowed types: :numbers, :division_completed (BCDD::Result::Expectations::Error::UnexpectedType)

result.handle do |on|
  on.failure(:err) { |_| :this_type_does_not_exist }
end
# type :err is not allowed. Allowed types: :numbers, :division_completed (BCDD::Result::Expectations::Error::UnexpectedType)
```

*PS: The `Divide` implementation is [here](#standalone-versus-mixin-mode).*

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### Type checking - Result Creation

The `BCDD::Result::Expectations` will be used on the result creation `Success()` and `Failure()` methods. So, when the result type is valid/expected, the result will be created. Otherwise, an error will be raised.

This works for both modes (standalone and mixin).

##### Mixin mode

```ruby
module Divide
  extend BCDD::Result::Expectations.mixin(success: :ok, failure: :err)

  def self.call(arg1, arg2)
    arg1.is_a?(Numeric) or return Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(Numeric) or return Failure(:invalid_arg, 'arg2 must be numeric')

    arg2.zero? and return Failure(:division_by_zero, 'arg2 must not be zero')

    Success(:division_completed, arg1 / arg2)
  end
end

Divide.call('4', 2)
# type :invalid_arg is not allowed. Allowed types: :err
# (BCDD::Result::Expectations::Error::UnexpectedType)

Divide.call(4, 2)
# type :division_completed is not allowed. Allowed types: :ok
# (BCDD::Result::Expectations::Error::UnexpectedType)
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

##### Standalone mode

```ruby
module Divide
  Expected = BCDD::Result::Expectations.new(success: :ok, failure: :err)

  def self.call(arg1, arg2)
    arg1.is_a?(Numeric) or return Expected::Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(Numeric) or return Expected::Failure(:invalid_arg, 'arg2 must be numeric')

    arg2.zero? and return Expected::Failure(:division_by_zero, 'arg2 must not be zero')

    Expected::Success(:division_completed, arg1 / arg2)
  end
end

Divide.call('4', 2)
# type :invalid_arg is not allowed. Allowed types: :err
# (BCDD::Result::Expectations::Error::UnexpectedType)

Divide.call(4, 2)
# type :division_completed is not allowed. Allowed types: :ok
# (BCDD::Result::Expectations::Error::UnexpectedType)
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### Value checking - Result Creation

The `Result::Expectations` supports types of validations. The first is the type checking only, and the second is the type and value checking.

To define expectations for your result's values, you must declare a Hash with the type as the key and the value as the value. A value validator is any object that responds to `#===` (case equality operator).

**Mixin mode:**

```ruby
module Divide
  extend BCDD::Result::Expectations.mixin(
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
    arg1.is_a?(Numeric) or return Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(Numeric) or return Failure(:invalid_arg, 'arg2 must be numeric')

    arg2.zero? and return Failure(:division_by_zero, 'arg2 must not be zero')

    Success(:division_completed, arg1 / arg2)
  end
end
```

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

The value validation will only be performed through the methods `Success()` and `Failure()`.

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

##### Success()

```ruby
Divide::Expected::Success(:ok)
# type :ok is not allowed. Allowed types: :numbers, :division_completed (BCDD::Result::Expectations::Error::UnexpectedType)

Divide::Expected::Success(:numbers, [1])
# value [1] is not allowed for :numbers type (BCDD::Result::Expectations::Error::UnexpectedValue)

Divide::Expected::Success(:division_completed, '2')
# value "2" is not allowed for :division_completed type (BCDD::Result::Expectations::Error::UnexpectedValue)
```

##### Failure()

```ruby
Divide::Expected::Failure(:err)
# type :err is not allowed. Allowed types: :invalid_arg, :division_by_zero (BCDD::Result::Expectations::Error::UnexpectedType)

Divide::Expected::Failure(:invalid_arg, :arg1_must_be_numeric)
# value :arg1_must_be_numeric is not allowed for :invalid_arg type (BCDD::Result::Expectations::Error::UnexpectedValue)

Divide::Expected::Failure(:division_by_zero, msg: 'arg2 must not be zero')
# value {:msg=>"arg2 must not be zero"} is not allowed for :division_by_zero type (BCDD::Result::Expectations::Error::UnexpectedValue)
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

## About

[Rodrigo Serradura](https://github.com/serradura) created this project. He is the B/CDD process/method creator and has already made similar gems like the [u-case](https://github.com/serradura/u-case) and [kind](https://github.com/serradura/kind/blob/main/lib/kind/result.rb). This gem is a general-purpose abstraction/monad, but it also contains key features that serve as facilitators for adopting B/CDD in the code.

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/B-CDD/bcdd-result. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/B-CDD/bcdd-result/blob/master/CODE_OF_CONDUCT.md).

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

## Code of Conduct

Everyone interacting in the BCDD::Result project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/B-CDD/bcdd-result/blob/master/CODE_OF_CONDUCT.md).
