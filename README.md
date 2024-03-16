<p align="center">
  <h1 align="center" id="-bcddresult">🔀 BCDD::Result</h1>
  <p align="center"><i>Unleash a pragmatic and observable use of Result Pattern and Railway-Oriented Programming in Ruby.</i></p>
  <p align="center">
    <img src="https://img.shields.io/badge/Ruby%20%3E%3D%202.7%2C%20%3C%3D%20Head-ruby.svg?colorA=444&colorB=333" alt="Ruby">
    <a href="https://rubygems.org/gems/bcdd-result"><img src="https://badge.fury.io/rb/bcdd-result.svg" alt="bcdd-result gem version" height="18"></a>
    <a href="https://codeclimate.com/github/B-CDD/result/maintainability"><img src="https://api.codeclimate.com/v1/badges/aa8360f8f012d7dedd62/maintainability" /></a>
    <a href="https://codeclimate.com/github/B-CDD/result/test_coverage"><img src="https://api.codeclimate.com/v1/badges/aa8360f8f012d7dedd62/test_coverage" /></a>
  </p>
</p>

It's a general-purpose result monad that allows you to create objects representing a success (`BCDD::Result::Success`) or failure (`BCDD::Result::Failure`).

**What problem does it solve?**

It allows you to consistently represent the concept of success and failure throughout your codebase.

Furthermore, this abstraction exposes several features that will be useful to make the application flow react cleanly and securely to the result represented by these objects.

Use it to enable the [Railway Oriented Programming](https://fsharpforfunandprofit.com/rop/) pattern (superpower) in your code.

- [Supported Ruby](#supported-ruby)
- [Installation](#installation)
- [Usage](#usage)
    - [`BCDD::Result` *versus* `Result`](#bcddresult-versus-result)
- [Reference](#reference)
  - [Basic methods](#basic-methods)
    - [Checking types with `result.is?` or `method missing`](#checking-types-with-resultis-or-method-missing)
    - [Checking types with `result.success?` or `result.failure?`](#checking-types-with-resultsuccess-or-resultfailure)
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
    - [`BCDD::Result.mixin`](#bcddresultmixin)
      - [Class example (Instance Methods)](#class-example-instance-methods)
      - [Module example (Singleton Methods)](#module-example-singleton-methods)
      - [Important Requirement](#important-requirement)
      - [Dependency Injection](#dependency-injection)
      - [Add-ons](#add-ons)
  - [`BCDD::Result::Expectations`](#bcddresultexpectations)
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
      - [Pattern Matching Support](#pattern-matching-support)
    - [`BCDD::Result::Expectations.mixin` add-ons](#bcddresultexpectationsmixin-add-ons)
  - [`BCDD::Context`](#bcddcontext)
    - [Defining successes and failures](#defining-successes-and-failures)
    - [Constant aliases](#constant-aliases)
    - [`BCDD::Context.mixin`](#bcddcontextmixin)
      - [Class example (Instance Methods)](#class-example-instance-methods-1)
      - [`and_expose`](#and_expose)
      - [Module example (Singleton Methods)](#module-example-singleton-methods-1)
    - [`BCDD::Context::Expectations`](#bcddcontextexpectations)
    - [Mixin add-ons](#mixin-add-ons)
- [Pattern Matching](#pattern-matching)
  - [`BCDD::Result`](#bcddresult)
    - [`Array`/`Find` patterns](#arrayfind-patterns)
    - [`Hash` patterns](#hash-patterns)
  - [`BCDD::Context`](#bcddcontext-1)
    - [`Array`/`Find` patterns](#arrayfind-patterns-1)
    - [`Hash` patterns](#hash-patterns-1)
  - [How to pattern match without the concept of success and failure](#how-to-pattern-match-without-the-concept-of-success-and-failure)
- [`BCDD::Result.event_logs`](#bcddresultevent_logs)
  - [`metadata: {ids:}`](#metadata-ids)
  - [Configuration](#configuration)
    - [Turning on/off](#turning-onoff)
    - [Setting a `trace_id` fetcher](#setting-a-trace_id-fetcher)
    - [Setting a `listener`](#setting-a-listener)
    - [Setting multiple `listeners`](#setting-multiple-listeners)
- [`BCDD::Result.configuration`](#bcddresultconfiguration)
  - [`BCDD::Result.config`](#bcddresultconfig)
- [`BCDD::Result#and_then!`](#bcddresultand_then)
    - [Dependency Injection](#dependency-injection-1)
    - [Configuration](#configuration-1)
    - [Analysis: Why is `and_then!` an Anti-pattern?](#analysis-why-is-and_then-an-anti-pattern)
    - [`#and_then` versus `#and_then!`](#and_then-versus-and_then)
    - [Analysis: Why is `#and_then` the antidote/standard?](#analysis-why-is-and_then-the-antidotestandard)
- [About](#about)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)

## Supported Ruby

This library is tested against:

Version | 2.7 | 3.0 | 3.1 | 3.2 | 3.3 | Head
---- | --- | --- | --- | --- | --- | ---
100% Coverage | ✅  | ✅  | ✅  | ✅  | ✅  | ✅

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bcdd-result'
```

And then execute:

    $ bundle install

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install bcdd-result

And require it in your code:

    require 'bcdd/result'

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

This gem provides a way to create constant aliases for `BCDD::Result` and other classes/modules.

To enable it, you must call the `BCDD::Result.configuration` method and pass a block to it. You can turn the aliases you want on/off in this block.

```ruby
BCDD::Result.configuration do |config|
  config.constant_alias.enable!('Result')
end
```

So, instead of using `BCDD::Result` everywhere, you can use `Result` as an alias/shortcut.

```ruby
Result::Success(:ok) # <BCDD::Result::Success type=:ok value=nil>

Result::Failure(:err) # <BCDD::Result::Failure type=:err value=nil>
```

If you have enabled constant aliasing, all examples in this README that use `BCDD::Result` can be implemented using `Result`.

There are other aliases and configurations available. Check the [BCDD::Result.configuration]() section for more information.

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

## Reference

### Basic methods

Both `BCDD::Result::Success` and `BCDD::Result::Failure` are composed of the same methods. Look at the basic ones:

**BCDD::Result::Success**

```ruby
################
# With a value #
################
result = BCDD::Result::Success(:ok, my: 'value')

result.success?   # true
result.failure?   # false
result.type?(:ok) # true
result.type       # :ok
result.value      # {:my => "value"}

###################
# Without a value #
###################
result = BCDD::Result::Success(:yes)

result.success?    # true
result.failure?    # false
result.type?(:yes) # true
result.type        # :yes
result.value       # nil
```

**BCDD::Result::Failure**

```ruby
################
# With a value #
################
result = BCDD::Result::Failure(:err, 'my_value')

result.success?    # false
result.failure?    # true
result.type?(:err) # true
result.type        # :err
result.value       # "my_value"

###################
# Without a value #
###################
result = BCDD::Result::Failure(:no)

result.success?   # false
result.failure?   # true
result.type?(:no) # true
result.type       # :no
result.value      # nil
```

In both cases, the `type` must be a symbol, and the `value` can be any kind of object.

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### Checking types with `result.is?` or `method missing`

Beyond the `type?` method, you can also use the `is?` method to check the result type. If you want to check the type directly, you can write the type using a method that ends with a question mark.

```ruby
result = BCDD::Result::Success(:ok)

result.is?(:ok) # true
result.ok?      # true

result = BCDD::Result::Failure(:err)

result.is?(:err) # true
result.err?      # true
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### Checking types with `result.success?` or `result.failure?`

`BCDD::Result#success?` and `BCDD::Result#failure?` are methods that allow you to check if the result is a success or a failure.

You can also check the result type by passing an argument to it. For example, `result.success?(:ok)` will check if the result is a success and if the type is `:ok`.

```ruby
result = BCDD::Result::Success(:ok)

result.success?(:ok)

# This is the same as:

result.success? && result.type == :ok
```

The same is valid for `BCDD::Result#failure?`.

```ruby
result = BCDD::Result::Failure(:err)

result.failure?(:err)

# This is the same as:

result.failure? && result.type == :err
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

### Result Hooks

Result hooks are methods that allow you to execute a block of code based on the type of result obtained.
To demonstrate their use, I will implement a method that can divide two numbers.

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

When you use `BCDD::Result#on`, the block will be executed only when the type matches the result type.

However, even if the block is executed, the method will always return the result itself.

The value of the result will be available as the first argument of the block.

```ruby
result = divide(nil, 2)
#<BCDD::Result::Failure type=:invalid_arg data='arg1 must be numeric'>

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

```ruby
result = divide(nil, 2)
#<BCDD::Result::Failure type=:invalid_arg data='arg1 must be numeric'>

output =
  result
    .on_type(:invalid_arg, :division_by_zero) { |msg| puts msg }
    .on_type(:division_completed) { |number| puts number }

# The code above will print 'arg1 must be numeric' and return the result itself.

result.object_id == output.object_id # true
```

*PS: The `divide()` implementation is [here](#result-hooks).*

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### `result.on_success`

The `BCDD::Result#on_success` method is quite similar to the `BCDD::Result#on` hook, but with a few key differences:

1. It will only execute the block of code if the result is a success.
2. If the type declaration is not included, the method will execute the block for any successful result, regardless of its type.

```ruby
# In both examples, it executes the block and returns the result itself.

divide(4, 2).on_success { |number| puts number }

divide(4, 2).on_success(:division_completed) { |number| puts number }

# It doesn't execute the block as the type is different.

divide(4, 4).on_success(:ok) { |value| puts value }

# It doesn't execute the block, as the result is a success, but the hook expects a failure.

divide(4, 4).on_failure { |error| puts error }
```

*PS: The `divide()` implementation is [here](#result-hooks).*

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### `result.on_failure`

It is the opposite of `Result#on_success`:

1. It will only execute the block of code if the result is a failure.
2. If the type declaration is not included, the method will execute the block for any failed result, regardless of its type.

```ruby
# In both examples, it executes the block and returns the result itself.

divide(nil, 2).on_failure { |error| puts error }

divide(4, 0).on_failure(:division_by_zero) { |error| puts error }

# It doesn't execute the block as the type is different.

divide(4, 0).on_failure(:invalid_arg) { |error| puts error }

# It doesn't execute the block, as the result is a failure, but the hook expects a success.

divide(4, 0).on_success { |number| puts number }
```

*PS: The `divide()` implementation is [here](#result-hooks).*

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### `result.on_unknown`

`BCDD::Result#on_unknown` will execute the block when no other hook (`#on`, `#on_type`, `#on_failure`, `#on_success`) has been executed.

Regardless of the block being executed, the method will always return the result itself.

The value of the result will be available as the first argument of the block.

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

This method lets you define blocks for each hook (type, failure, or success), but instead of returning itself, it will return the output of the first match/block execution.

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
* If the type is missing, it will execute the block for any success or failure handler.
* The `#type` and `#[]` handlers require at least one type/argument.

*PS: The `divide()` implementation is [here](#result-hooks).*

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

### Result Value

To access the result value, you can simply call `BCDD::Result#value`.

However, there may be instances where you need to retrieve the value of a successful result or a default value if the result is a failure. In such cases, you can make use of `BCDD::Result#value_or`.

#### `result.value_or`

`BCCD::Result#value_or` returns the value when the result is a success. However, if it is a failure, the given block will be executed, and its outcome will be returned.

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

The `BCDD::Result#data` exposes the result attributes (kind, type, value) directly and as a hash (`to_h`/`to_hash`) and array (`to_a`/`to_ary`).

This is helpful if you need to access the result attributes generically or want to use Ruby features like splat (`*`) and double splat (`**`) operators.

See the examples below to understand how to use it.

```ruby
result = BCDD::Result::Success(:ok, 1)

success_data = result.data # #<BCDD::Result::Data kind=:success type=:ok value=1>

success_data.kind  # :success
success_data.type  # :ok
success_data.value # 1

success_data.to_h  # {:kind=>:success, :type=>:ok, :value=>1}
success_data.to_a  # [:success, :ok, 1]

kind, type, value = success_data

[kind, type, value] # [:success, :ok, 1]

def print_to_ary(kind, type, value)
  puts [kind, type, value].inspect
end

def print_to_hash(kind:, type:, value:)
  puts [kind, type, value].inspect
end

print_to_ary(*success_data)   # [:success, :ok, 1]

print_to_hash(**success_data) # [:success, :ok, 1]
```

> **NOTE:** The example above uses a success result, but the same is valid for a failure result.

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

### Railway Oriented Programming

["Railway Oriented Programming (ROP)"](https://fsharpforfunandprofit.com/rop/)  is a programming technique that involves linking blocks together to form a sequence of operations, also known as a pipeline.
If a failure occurs in any of the blocks, the pipeline is interrupted and subsequent blocks are skipped.

The ROP technique allows you to structure your code in a way that expresses your logic as a series of operations, with the added benefit of stopping the process at the first detection of failure.

If all blocks successfully execute, the final result of the pipeline will be a success.

#### `result.and_then`

```ruby
module Divide
  extend self

  def call(arg1, arg2)
    validate_numbers(arg1, arg2)
      .and_then { |numbers| validate_nonzero(numbers) }
      .and_then { |numbers| divide(numbers) }
  end

  private

  def validate_numbers(arg1, arg2)
    arg1.is_a?(::Numeric) or return BCDD::Result::Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(::Numeric) or return BCDD::Result::Failure(:invalid_arg, 'arg2 must be numeric')

    BCDD::Result::Success(:ok, [arg1, arg2])
  end

  def validate_nonzero(numbers)
    return BCDD::Result::Success(:ok, numbers) if numbers.last.nonzero?

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

#### `BCDD::Result.mixin`

This method generates a module that any object can include or extend. It adds two methods to the target object: `Success()` and `Failure()`.

The main difference between these methods and `BCDD::Result::Success()`/`BCDD::Result::Failure()` is that the former will utilize the target object (which has received the include/extend) as the result's source.

Because the result has a source, the `#and_then` method can call methods from it.

##### Class example (Instance Methods)

```ruby
class Divide
  include BCDD::Result.mixin

  attr_reader :arg1, :arg2

  def initialize(arg1, arg2)
    @arg1 = arg1
    @arg2 = arg2
  end

  def call
    validate_numbers
      .and_then(:validate_nonzero)
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

  def validate_nonzero(numbers)
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
  extend self, BCDD::Result.mixin

  def call(arg1, arg2)
    validate_numbers(arg1, arg2)
      .and_then(:validate_nonzero)
      .and_then(:divide)
  end

  private

  def validate_numbers(arg1, arg2)
    arg1.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg2 must be numeric')

    Success(:ok, [arg1, arg2])
  end

  def validate_nonzero(numbers)
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

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

##### Important Requirement

To use the `#and_then` method to call methods, they must use `Success()` and `Failure()` to produce the results.

If you try to use `BCDD::Result::Success()`/`BCDD::Result::Failure()`, or results from another `BCDD::Result.mixin` instance with `#and_then`, it will raise an error because the sources are different.

**Note:** You can still use the block syntax, but all the results must be produced by the source's `Success()` and `Failure()` methods.

```ruby
module ValidateNonzero
  extend self, BCDD::Result.mixin

  def call(numbers)
    return Success(:ok, numbers) unless numbers.last.zero?

    Failure(:division_by_zero, 'arg2 must not be zero')
  end
end

module Divide
  extend self, BCDD::Result.mixin

  def call(arg1, arg2)
    validate_numbers(arg1, arg2)
      .and_then(:validate_nonzero)
      .and_then(:divide)
  end

  private

  def validate_numbers(arg1, arg2)
    arg1.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg2 must be numeric')

    Success(:ok, [arg1, arg2])
  end

  def validate_nonzero(numbers)
    ValidateNonzero.call(numbers) # This will raise an error
  end

  def divide((number1, number2))
    Success(:division_completed, number1 / number2)
  end
end
```

Look at the error produced by the code above:

```ruby
Divide.call(2, 0)

# You cannot call #and_then and return a result that does not belong to the same source! (BCDD::Result::Error::InvalidResultSource)
# Expected source: Divide
# Given source: ValidateNonzero
# Given result: #<BCDD::Result::Failure type=:division_by_zero value="arg2 must not be zero">
```

In order to fix this, you must handle the result produced by `ValidateNonzero.call()` and return a result that belongs to the same source.

```ruby
module ValidateNonzero
  extend self, BCDD::Result.mixin

  def call(numbers)
    return Success(:ok, numbers) unless numbers.last.zero?

    Failure(:division_by_zero, 'arg2 must not be zero')
  end
end

module Divide
  extend self, BCDD::Result.mixin

  def call(arg1, arg2)
    validate_numbers(arg1, arg2)
      .and_then(:validate_nonzero)
      .and_then(:divide)
  end

  private

  def validate_numbers(arg1, arg2)
    arg1.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg2 must be numeric')

    Success(:ok, [arg1, arg2])
  end

  def validate_nonzero(numbers)
    # In this case we are handling the result from other source
    # and returning our own
    ValidateNonzero.call(numbers).handle do |on|
      on.success { |numbers| Success(:ok, numbers) }

      on.failure { |err| Failure(:division_by_zero, err) }
    end
  end

  def divide((number1, number2))
    Success(:division_completed, number1 / number2)
  end
end
```

Look at the output of the code above:

```ruby
Divide.call(2, 0)

#<BCDD::Result::Failure type=:division_by_zero value="arg2 must not be zero">
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

##### Dependency Injection

The `BCDD::Result#and_then` accepts a second argument that will be used to share a value with the source's method.
To receive this argument, the source's method must have an arity of two, where the first argument will be the result value and the second will be the injected value.

```ruby
require 'logger'

module Divide
  extend self, BCDD::Result.mixin

  def call(arg1, arg2, logger: ::Logger.new(STDOUT))
    validate_numbers(arg1, arg2)
      .and_then(:validate_nonzero, logger)
      .and_then(:divide, logger)
  end

  private

  def validate_numbers(arg1, arg2)
    arg1.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg2 must be numeric')

    Success(:ok, [arg1, arg2])
  end

  def validate_nonzero(numbers, logger)
    if numbers.last.zero?
      logger.error('arg2 must not be zero')

      Failure(:division_by_zero, 'arg2 must not be zero')
    else
      logger.info('The numbers are valid')

      Success(:ok, numbers)
    end
  end

  def divide((number1, number2), logger)
    division = number1 / number2

    logger.info("The division result is #{division}")

    Success(:division_completed, division)
  end
end

Divide.call(4, 2)
# I, [2023-10-11T00:08:05.546237 #18139]  INFO -- : The numbers are valid
# I, [2023-10-11T00:08:05.546337 #18139]  INFO -- : The division result is 2
#=> #<BCDD::Result::Success type=:division_completed value=2>

Divide.call(4, 2, logger: Logger.new(IO::NULL))
#=> #<BCDD::Result::Success type=:division_completed value=2>
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

##### Add-ons

The `BCDD::Result.mixin` also accepts the `config:` argument. It is a hash that will be used to define custom behaviors for the mixin.

**given**

This addon is enabled by default. It will create the `Given(value)` method. Use it to add a value to the result chain and invoke the next step (through `and_then`).

You can turn it off by passing `given: false` to the `config:` argument or using the `BCDD::Result.configuration`.

**continue**

This addon will create the `Continue(value)` method and change the `Success()` behavior to terminate the step chain.

So, if you want to advance to the next step, you must use `Continue(value)` instead of `Success(type, value)`. Otherwise, the step chain will be terminated.

In this example below, the `validate_nonzero` will return a `Success(:division_completed, 0)` and terminate the chain if the first number is zero.

```ruby
module Divide
  extend self, BCDD::Result.mixin(config: { addon: { continue: true } })

  def call(arg1, arg2)
    Given([arg1, arg2])
      .and_then(:validate_numbers)
      .and_then(:validate_nonzero)
      .and_then(:divide)
  end

  private

  def validate_numbers(numbers)
    number1, number2 = numbers

    number1.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg1 must be numeric')
    number2.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg2 must be numeric')

    Continue(numbers)
  end

  def validate_nonzero(numbers)
    return Failure(:division_by_zero, 'arg2 must not be zero') if numbers.last.zero?

    return Success(:division_completed, 0) if numbers.first.zero?

    Continue(numbers)
  end

  def divide((number1, number2))
    Success(:division_completed, number1 / number2)
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
  Result = BCDD::Result::Expectations.new(
    success: %i[numbers division_completed],
    failure: %i[invalid_arg division_by_zero]
  )

  def self.call(arg1, arg2)
    arg1.is_a?(Numeric) or return Result::Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(Numeric) or return Result::Failure(:invalid_arg, 'arg2 must be numeric')

    arg2.zero? and return Result::Failure(:division_by_zero, 'arg2 must not be zero')

    Result::Success(:division_completed, arg1 / arg2)
  end
end
```

In the code above, we define a constant `Divide::Result`. And because of this (it is a constant), we can use it inside and outside the module.

Look what happens if you try to create a result without one of the expected types.

```ruby
Divide::Result::Success(:ok)
# type :ok is not allowed. Allowed types: :numbers, :division_completed
# (BCDD::Result::Contract::Error::UnexpectedType)

Divide::Result::Failure(:err)
# type :err is not allowed. Allowed types: :invalid_arg, :division_by_zero
# (BCDD::Result::Contract::Error::UnexpectedType)
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
      .and_then(:validate_nonzero)
      .and_then(:divide)
  end

  private

  def validate_numbers(arg1, arg2)
    arg1.is_a?(Numeric) or return Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(Numeric) or return Failure(:invalid_arg, 'arg2 must be numeric')

    Success(:numbers, [arg1, arg2])
  end

  def validate_nonzero(numbers)
    return Success(:numbers, numbers) unless numbers.last.zero?

    Failure(:division_by_zero, 'arg2 must not be zero')
  end

  def divide((number1, number2))
    Success(:division_completed, number1 / number2)
  end
end
```

This mode also defines an `Result` constant to be used inside and outside the module.

> **PROTIP:**
> You can use the `Result` constant to mock the result's type and value in your tests. As they will have the exact expectations, your tests will check if the result clients are handling the result correctly.

Now that you know the two modes, let's understand how expectations can be beneficial and powerful for defining contracts.

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### Type checking - Result Hooks

The `BCDD::Result::Expectations` will check if the type of the result is valid. This checking will be performed in all methods that depend on the result’s type, such as `#success?`, `#failure?`, `#on`, `#on_type`, `#on_success`, `#on_failure`, and `#handle`.

##### `#success?` and `#failure?`

When checking whether a result is a success or failure, `BCDD::Result::Expectations` will also verify if the result type is valid/expected. In case of an invalid type, an error will be raised.

**Success example:**

```ruby
result = Divide.new.call(10, 2)

result.success?                      # true
result.success?(:numbers)            # false
result.success?(:division_completed) # true

result.success?(:ok)
# type :ok is not allowed. Allowed types: :numbers, :division_completed
# (BCDD::Result::Contract::Error::UnexpectedType)
```

**Failure example:**

```ruby
result = Divide.new.call(10, '2')

result.failure?                    # true
result.failure?(:invalid_arg)      # true
result.failure?(:division_by_zero) # false

result.failure?(:err)
# type :err is not allowed. Allowed types: :invalid_arg, :division_by_zero
# (BCDD::Result::Contract::Error::UnexpectedType)
```

*PS: The `Divide` implementation is [here](#standalone-versus-mixin-mode).*

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

##### `#on` and `#on_type`

If you use `#on` or `#on_type` to execute a block, `BCDD::Result::Expectations` will check whether the result type is valid/expected. Otherwise, an error will be raised.

```ruby
result = Divide.new.call(10, 2)

result
  .on(:invalid_arg, :division_by_zero) { |msg| puts msg }
  .on(:division_completed) { |number| puts "The result is #{number}" }

# The code above will print 'The result is 5'

result.on(:number) { |_| :this_type_does_not_exist }
# type :number is not allowed. Allowed types: :numbers, :division_completed, :invalid_arg, :division_by_zero
# (BCDD::Result::Contract::Error::UnexpectedType)
```

*PS: The `Divide` implementation is [here](#standalone-versus-mixin-mode).*

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

##### `#on_success` and `#on_failure`

If you use `#on_success` or `#on_failure` to execute a block, `BCDD::Result::Expectations` will check whether the result type is valid/expected. Otherwise, an error will be raised.

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
# (BCDD::Result::Contract::Error::UnexpectedType)

result.on_failure(:err) { |_| :this_type_does_not_exist }
# type :err is not allowed. Allowed types: :invalid_arg, :division_by_zero
# (BCDD::Result::Contract::Error::UnexpectedType)
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
# type :ok is not allowed. Allowed types: :numbers, :division_completed, :invalid_arg, :division_by_zero (BCDD::Result::Contract::Error::UnexpectedType)

result.handle do |on|
  on.success(:ok) { |_| :this_type_does_not_exist }
end
# type :ok is not allowed. Allowed types: :numbers, :division_completed (BCDD::Result::Contract::Error::UnexpectedType)

result.handle do |on|
  on.failure(:err) { |_| :this_type_does_not_exist }
end
# type :err is not allowed. Allowed types: :invalid_arg, :division_by_zero (BCDD::Result::Contract::Error::UnexpectedType)
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
# (BCDD::Result::Contract::Error::UnexpectedType)

Divide.call(4, 2)
# type :division_completed is not allowed. Allowed types: :ok
# (BCDD::Result::Contract::Error::UnexpectedType)
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

##### Standalone mode

```ruby
module Divide
  Result = BCDD::Result::Expectations.new(success: :ok, failure: :err)

  def self.call(arg1, arg2)
    arg1.is_a?(Numeric) or return Result::Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(Numeric) or return Result::Failure(:invalid_arg, 'arg2 must be numeric')

    arg2.zero? and return Result::Failure(:division_by_zero, 'arg2 must not be zero')

    Result::Success(:division_completed, arg1 / arg2)
  end
end

Divide.call('4', 2)
# type :invalid_arg is not allowed. Allowed types: :err
# (BCDD::Result::Contract::Error::UnexpectedType)

Divide.call(4, 2)
# type :division_completed is not allowed. Allowed types: :ok
# (BCDD::Result::Contract::Error::UnexpectedType)
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### Value checking - Result Creation

The `Result::Expectations` supports two types of validations. The first is the type checking only, and the second is the type and value checking.

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
  Result = BCDD::Result::Expectations.new(
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
    arg1.is_a?(Numeric) or return Result::Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(Numeric) or return Result::Failure(:invalid_arg, 'arg2 must be numeric')

    arg2.zero? and return Result::Failure(:division_by_zero, 'arg2 must not be zero')

    Result::Success(:division_completed, arg1 / arg2)
  end
end
```

The value validation will only be performed through the methods `Success()` and `Failure()`.

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

##### Success()

```ruby
Divide::Result::Success(:ok)
# type :ok is not allowed. Allowed types: :numbers, :division_completed (BCDD::Result::Contract::Error::UnexpectedType)

Divide::Result::Success(:numbers, [1])
# value [1] is not allowed for :numbers type (BCDD::Result::Contract::Error::UnexpectedValue)

Divide::Result::Success(:division_completed, '2')
# value "2" is not allowed for :division_completed type (BCDD::Result::Contract::Error::UnexpectedValue)
```

##### Failure()

```ruby
Divide::Result::Failure(:err)
# type :err is not allowed. Allowed types: :invalid_arg, :division_by_zero (BCDD::Result::Contract::Error::UnexpectedType)

Divide::Result::Failure(:invalid_arg, :arg1_must_be_numeric)
# value :arg1_must_be_numeric is not allowed for :invalid_arg type (BCDD::Result::Contract::Error::UnexpectedValue)

Divide::Result::Failure(:division_by_zero, msg: 'arg2 must not be zero')
# value {:msg=>"arg2 must not be zero"} is not allowed for :division_by_zero type (BCDD::Result::Contract::Error::UnexpectedValue)
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

##### Pattern Matching Support

The value checking has support for handling pattern-matching errors, and the cleanest way to do it is using the one-line pattern matching operators (`=>` since Ruby 3.0) and (`in` Ruby 2.7).

How does this operator work? They raise an error when the pattern does not match but returns nil when it matches.

Because of this, you will need to enable `nil` as a valid value checking. You can do it through the `BCDD::Result.configuration` or by allowing it directly on the mixin config.

```ruby
module Divide
  extend BCDD::Result::Expectations.mixin(
    config: {
      pattern_matching: { nil_as_valid_value_checking: true }
    },
    success: {
      division_completed: ->(value) { value => (Integer | Float) }
    },
    failure: { invalid_arg: String, division_by_zero: String }
  )

  def self.call(arg1, arg2)
    arg1.is_a?(Numeric) or return Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(Numeric) or return Failure(:invalid_arg, 'arg2 must be numeric')

    arg2.zero? and return Failure(:division_by_zero, 'arg2 must not be zero')

    Success(:division_completed, String(arg1 / arg2))
  end
end

Divide.call(10, 5)
# value "2" is not allowed for :division_completed type ("2": Float === "2" does not return true) (BCDD::Result::Contract::Error::UnexpectedValue)
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### `BCDD::Result::Expectations.mixin` add-ons

The `BCDD::Result::Expectations.mixin` also accepts the `config:` argument. It is a hash that can be used to define custom behaviors for the mixin.

**Continue**

It is similar to `BCDD::Result.mixin(config: { addon: { continue: true } })`. The key difference is that the expectations will ignore the `Continue(value)`.

Based on this, use the `Success()` to produce a terminal result and `Continue()` to produce a result that will be used in the next step.

```ruby
class Divide
  include BCDD::Result::Expectations.mixin(
    config: { addon: { continue: true } },
    success: :division_completed,
    failure: %i[invalid_arg division_by_zero]
  )

  def call(arg1, arg2)
    validate_numbers(arg1, arg2)
      .and_then(:validate_nonzero)
      .and_then(:divide)
  end

  private

  def validate_numbers(arg1, arg2)
    arg1.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg2 must be numeric')

    Continue([arg1, arg2])
  end

  def validate_nonzero(numbers)
    return Continue(numbers) unless numbers.last.zero?

    Failure(:division_by_zero, 'arg2 must not be zero')
  end

  def divide((number1, number2))
    Success(:division_completed, number1 / number2)
  end
end

result = Divide.new.call(4, 2)
# => #<BCDD::Result::Success type=:division_completed value=2>

# The example below shows an error because the :ok type is not allowed.
# But look at the allowed types have only one type (:division_completed).
# This is because the :_continue_ type is ignored by the expectations.
#
result.success?(:ok)
# type :ok is not allowed. Allowed types: :division_completed (BCDD::Result::Contract::Error::UnexpectedType)
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

### `BCDD::Context`

The `BCDD::Context` is a `BCDD::Result`, meaning it has all the features of the `BCDD::Result`. The main difference is that it only accepts keyword arguments as a value, which applies to the `and_then`: The called methods must receive keyword arguments, and the dependency injection will be performed through keyword arguments.

As the input/output are hashes, the results of each `and_then` call will automatically accumulate. This is useful in operations chaining, as the result of the previous operations will be automatically available for the next one. Because of this behavior, the `BCDD::Context` has the `#and_expose` method to expose only the desired keys from the accumulated result.

#### Defining successes and failures

As the `BCDD::Result`, you can declare success and failures directly from `BCDD::Context`.

```ruby
BCDD::Context::Success(:ok, a: 1, b: 2)
#<BCDD::Context::Success type=:ok value={:a=>1, :b=>2}>

BCDD::Context::Failure(:err, message: 'something went wrong')
#<BCDD::Context::Failure type=:err value={:message=>"something went wrong"}>
```

But different from `BCDD::Result` that accepts any value, the `BCDD::Context` only takes keyword arguments.

```ruby
BCDD::Context::Success(:ok, [1, 2])
# wrong number of arguments (given 2, expected 1) (ArgumentError)

BCDD::Context::Failure(:err, { message: 'something went wrong' })
# wrong number of arguments (given 2, expected 1) (ArgumentError)

#
# Use ** to convert a hash to keyword arguments
#
BCDD::Context::Success(:ok, **{ message: 'hashes can be converted to keyword arguments' })
#<BCDD::Context::Success type=:ok value={:message=>"hashes can be converted to keyword arguments"}>
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### Constant aliases

You can configure `Context` or `BCDD::Context` as an alias for `BCDD::Context`. This is helpful to define a standard way to avoid the full constant name/path in your code.

```ruby
BCDD::Result.configuration do |config|
  config.context_alias.enable!('BCDD::Context')

  # or

  config.context_alias.enable!('Context')
end
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### `BCDD::Context.mixin`

As in the `BCDD::Result`, you can use the `BCDD::Context.mixin` to add the `Success()` and `Failure()` methods to your classes/modules.

Let's see this feature and the data accumulation in action:

##### Class example (Instance Methods)

```ruby
require 'logger'

class Divide
  include BCDD::Context.mixin

  def call(arg1, arg2, logger: ::Logger.new(STDOUT))
    validate_numbers(arg1, arg2)
      .and_then(:validate_nonzero)
      .and_then(:divide, logger: logger)
  end

  private

  def validate_numbers(arg1, arg2)
    arg1.is_a?(::Numeric) or return Failure(:err, message: 'arg1 must be numeric')
    arg2.is_a?(::Numeric) or return Failure(:err, message: 'arg2 must be numeric')

    Success(:ok, number1: arg1, number2: arg2)
  end

  def validate_nonzero(number2:, **)
    return Success(:ok) if number2.nonzero?

    Failure(:err, message: 'arg2 must not be zero')
  end

  #
  # The logger was injected via #and_then and keyword arguments
  #
  def divide(number1:, number2:, logger:)
    result = number1 / number2

    logger.info("The division result is #{result}")

    Success(:ok, number: result)
  end
end

Divide.new.call(10, 5)
# I, [2023-10-27T01:51:46.905004 #76915]  INFO -- : The division result is 2
#<BCDD::Context::Success type=:ok value={:number=>2}>

Divide.new.call('10', 5)
#<BCDD::Context::Failure type=:err value={:message=>"arg1 must be numeric"}>

Divide.new.call(10, '5')
#<BCDD::Context::Failure type=:err value={:message=>"arg2 must be numeric"}>

Divide.new.call(10, 0)
#<BCDD::Context::Failure type=:err value={:message=>"arg2 must not be zero"}>
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

##### `and_expose`

This allows you to expose only the desired keys from the accumulated result. It can be used with any `BCDD::Context` object.

Let's add it to the previous example:

```ruby
class Divide
  include BCDD::Context.mixin

  def call(arg1, arg2)
    validate_numbers(arg1, arg2)
      .and_then(:validate_nonzero)
      .and_then(:divide)
      .and_expose(:division_completed, [:number])
  end

  private

  def validate_numbers(arg1, arg2)
    arg1.is_a?(::Numeric) or return Failure(:err, message: 'arg1 must be numeric')
    arg2.is_a?(::Numeric) or return Failure(:err, message: 'arg2 must be numeric')

    Success(:ok, number1: arg1, number2: arg2)
  end

  def validate_nonzero(number2:, **)
    return Success(:ok) if number2.nonzero?

    Failure(:err, message: 'arg2 must not be zero')
  end

  def divide(**input)
    Success(:ok, number: input.values.reduce(:/), **input)
  end
end

Divide.new.call(10, 5)
#<BCDD::Context::Success type=:division_completed value={:number=>2}>
```

As you can see, even with `divide` success exposing the division number with all the accumulated data (`**input`), the `#and_expose` could generate a new success with a new type and only with the desired keys.

Remove the `#and_expose` call to see the difference. This will be the outcome:

```ruby
Divide.new.call(10, 5)
#<BCDD::Context::Success type=:ok value={:number=>2, :number1=>10, :number2=>5}>
```

> PS: The `#and_expose` produces a terminal success by default. This means the next step will not be executed even if you call `#and_then` after `#and_expose`. To change this behavior, you can pass `terminal: false` to `#and_expose`.

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

##### Module example (Singleton Methods)

`BCDD::Context.mixin` can also produce singleton methods. Below is an example using a module (but it could be a class, too).

```ruby
module Divide
  extend self, BCDD::Context.mixin

  def call(arg1, arg2)
    validate_numbers(arg1, arg2)
      .and_then(:validate_nonzero)
      .and_then(:divide)
      .and_expose(:division_completed, [:number])
  end

  private

  def validate_numbers(arg1, arg2)
    arg1.is_a?(::Numeric) or return Failure(:err, message: 'arg1 must be numeric')
    arg2.is_a?(::Numeric) or return Failure(:err, message: 'arg2 must be numeric')

    Success(:ok, number1: arg1, number2: arg2)
  end

  def validate_nonzero(number2:, **)
    return Success(:ok) if number2.nonzero?

    Failure(:err, message: 'arg2 must not be zero')
  end

  def divide(number1:, number2:)
    Success(:ok, number: number1 / number2)
  end
end

Divide.call(10, 5)
#<BCDD::Context::Success type=:division_completed value={:number=>2}>

Divide.call('10', 5)
#<BCDD::Context::Failure type=:err value={:message=>"arg1 must be numeric"}>

Divide.call(10, '5')
#<BCDD::Context::Failure type=:err value={:message=>"arg2 must be numeric"}>

Divide.call(10, 0)
#<BCDD::Context::Failure type=:err value={:message=>"arg2 must not be zero"}>
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### `BCDD::Context::Expectations`

The `BCDD::Context::Expectations` is a `BCDD::Result::Expectations` with the `BCDD::Context` features.

This is an example using the mixin mode, but the standalone mode is also supported.

```ruby
class Divide
  include BCDD::Context::Expectations.mixin(
    config: {
      pattern_matching: { nil_as_valid_value_checking: true }
    },
    success: {
      division_completed: ->(value) { value => { number: Numeric } }
    },
    failure: {
      invalid_arg:      ->(value) { value => { message: String } },
      division_by_zero: ->(value) { value => { message: String } }
    }
  )

  def call(arg1, arg2)
    arg1.is_a?(Numeric) or return Failure(:invalid_arg, message: 'arg1 must be numeric')
    arg2.is_a?(Numeric) or return Failure(:invalid_arg, message: 'arg2 must be numeric')

    arg2.zero? and return Failure(:division_by_zero, message: 'arg2 must not be zero')

    Success(:division_completed, number: (arg1 / arg2))
  end
end

Divide.new.call(10, 5)
#<BCDD::Context::Success type=:division_completed value={:number=>2}>
```

As in the `BCDD::Result::Expectations.mixin`, the `BCDD::Context::Expectations.mixin` will add a Result constant in the target class. It can generate success/failure results, which ensure the mixin expectations.

Let's see this using the previous example:

```ruby
Divide::Result::Success(:division_completed, number: 2)
#<BCDD::Context::Success type=:division_completed value={:number=>2}>

Divide::Result::Success(:division_completed, number: '2')
# value {:number=>"2"} is not allowed for :division_completed type ({:number=>"2"}: Numeric === "2" does not return true) (BCDD::Result::Contract::Error::UnexpectedValue)
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### Mixin add-ons

The `BCDD::Context.mixin` and `BCDD::Context::Expectations.mixin` also accepts the `config:` argument. And it works the same way as the `BCDD::Result` mixins.

**given**

This addon is enabled by default. It will create the `Given(*value)` method. Use it to add a value to the result chain and invoke the next step (through `and_then`).

You can turn it off by passing `given: false` to the `config:` argument or using the `BCDD::Result.configuration`.

The `Given()` addon for a BCDD::Context can be called with one or more arguments. The arguments will be converted to a hash (`to_h`) and merged to define the first value of the result chain.

**continue**

The `BCDD::Context.mixin(config: { addon: { continue: true } })` or `BCDD::Context::Expectations.mixin(config: { addon: { continue: true } })` creates the `Continue(value)` method and change the `Success()` behavior to terminate the step chain.

So, if you want to advance to the next step, you must use `Continue(**value)` instead of `Success(type, **value)`. Otherwise, the step chain will be terminated.

Let's use a mix of `BCDD::Context` features to see in action with this add-on:

```ruby
module Division
  require 'logger'

  extend self, BCDD::Context::Expectations.mixin(
    config: {
      addon:            { continue: true },
      pattern_matching: { nil_as_valid_value_checking: true }
    },
    success: {
      division_completed: ->(value) { value => { number: Numeric } }
    },
    failure: {
      invalid_arg:      ->(value) { value => { message: String } },
      division_by_zero: ->(value) { value => { message: String } }
    }
  )

  def call(arg1, arg2, logger: ::Logger.new(STDOUT))
    Given(number1: arg1, number2: arg2)
      .and_then(:require_numbers)
      .and_then(:check_for_zeros)
      .and_then(:divide, logger: logger)
      .and_expose(:division_completed, [:number])
  end

  private

  def require_numbers(number1:, number2:)
    number1.is_a?(::Numeric) or return Failure(:invalid_arg, message: 'arg1 must be numeric')
    number2.is_a?(::Numeric) or return Failure(:invalid_arg, message: 'arg2 must be numeric')

    Continue()
  end

  def check_for_zeros(number1:, number2:)
    return Failure(:division_by_zero, message: 'arg2 must not be zero') if number2.zero?

    return Success(:division_completed, number: 0) if number1.zero?

    Continue()
  end

  def divide(number1:, number2:, logger:)
    result = number1 / number2

    logger.info("The division result is #{result}")

    Continue(number: result)
  end
end

Division.call(14, 2)
# I, [2023-10-27T02:01:05.812388 #77823]  INFO -- : The division result is 7
#<BCDD::Context::Success type=:division_completed value={:number=>7}>

Division.call(0, 2)
##<BCDD::Context::Success type=:division_completed value={:number=>0}>

Division.call('14', 2)
#<BCDD::Context::Failure type=:invalid_arg value={:message=>"arg1 must be numeric"}>

Division.call(14, '2')
#<BCDD::Context::Failure type=:invalid_arg value={:message=>"arg2 must be numeric"}>

Division.call(14, 0)
#<BCDD::Context::Failure type=:division_by_zero value={:message=>"arg2 must not be zero"}>
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

## Pattern Matching

The `BCDD::Result` and `BCDD::Context` also provides support to pattern matching.

### `BCDD::Result`

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
in BCDD::Failure[:invalid_arg, msg] then puts msg
in BCDD::Failure[:division_by_zero, msg] then puts msg
in BCDD::Success[:division_completed, num] then puts num
end

# The code above will print: 2

case Divide.call(4, 0)
in BCDD::Failure[:invalid_arg, msg] then puts msg
in BCDD::Failure[:division_by_zero, msg] then puts msg
in BCDD::Success[:division_completed, num] then puts num
end

# The code above will print: arg2 must not be zero
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### `Hash` patterns

```ruby
case Divide.call(10, 2)
in BCDD::Failure(type: :invalid_arg, value: msg) then puts msg
in BCDD::Failure(type: :division_by_zero, value: msg) then puts msg
in BCDD::Success(type: :division_completed, value: num) then puts num
end

# The code above will print: 5

case Divide.call('10', 2)
in BCDD::Failure(type: :invalid_arg, value: msg) then puts msg
in BCDD::Failure(type: :division_by_zero, value: msg) then puts msg
in BCDD::Success(type: :division_completed, value: num) then puts num
end

# The code above will print: arg1 must be numeric
```

You can also use `BCDD::Result::Success` and `BCDD::Result::Failure` as patterns.

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>


### `BCDD::Context`

In the further examples, I will use the `Divide` lambda to exemplify its usage.

```ruby
Divide = lambda do |arg1, arg2|
  arg1.is_a?(::Numeric) or return BCDD::Context::Failure(:invalid_arg, err: 'arg1 must be numeric')
  arg2.is_a?(::Numeric) or return BCDD::Context::Failure(:invalid_arg, err: 'arg2 must be numeric')

  return BCDD::Context::Failure(:division_by_zero, err: 'arg2 must not be zero') if arg2.zero?

  BCDD::Context::Success(:division_completed, num: arg1 / arg2)
end
```

#### `Array`/`Find` patterns

```ruby
case Divide.call(4, 2)
in BCDD::Failure[:invalid_arg, {msg:}] then puts msg
in BCDD::Failure[:division_by_zero, {msg:}] then puts msg
in BCDD::Success[:division_completed, {num:}] then puts num
end

# The code above will print: 2

case Divide.call(4, 0)
in BCDD::Failure[:invalid_arg, {msg:}] then puts msg
in BCDD::Failure[:division_by_zero, {msg:}] then puts msg
in BCDD::Success[:division_completed, {num:}] then puts num
end

# The code above will print: arg2 must not be zero
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### `Hash` patterns

If you don't provide the keys :type and :value, the pattern will match the result value.

```ruby
case Divide.call(10, 2)
in BCDD::Failure({msg:}) then puts msg
in BCDD::Success({num:}) then puts num
end
```

```ruby
case Divide.call(10, 2)
in BCDD::Failure(type: :invalid_arg, value: {msg:}) then puts msg
in BCDD::Failure(type: :division_by_zero, value: {msg:}) then puts msg
in BCDD::Success(type: :division_completed, value: {num:}) then puts num
end

# The code above will print: 5

case Divide.call('10', 2)
in BCDD::Failure(type: :invalid_arg, value: {msg:}) then puts {msg:}
in BCDD::Failure(type: :division_by_zero, value: {msg:}) then puts msg
in BCDD::Success(type: :division_completed, value: {num:}) then puts num
end

# The code above will print: arg1 must be numeric
```

You can also use `BCDD::Context::Success` and `BCDD::Context::Failure` as patterns.

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

### How to pattern match without the concept of success and failure

You can use the classes `BCDD::Result` and `BCDD::Context` as patterns, and the pattern matching will work without the concept of success and failure.

```ruby
case Divide.call(10, 2)
in BCDD::Context(:invalid_arg, {msg:}) then puts msg
in BCDD::Context(:division_by_zero, {msg:}) then puts msg
in BCDD::Context(:division_completed, {num:}) then puts num
end

case Divide.call(10, 2)
in BCDD::Result(:invalid_arg, msg) then puts msg
in BCDD::Result(:division_by_zero, msg) then puts msg
in BCDD::Result(:division_completed, num) then puts num
end
```

The `BCDD::Result` will also work with the `BCDD::Context`, but the opposite won't.

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

## `BCDD::Result.event_logs`

Use `BCDD::Result.event_logs(&block)` to track all the results produced in the same or between different operations (it works with `BCDD::Result` and `BCDD::Context`). When there is a nesting of `event_logs` blocks, this mechanism will be able to correlate parent and child blocks and present the duration of all operations in milliseconds.

When you wrap the creation of the result with `BCDD::Result.event_logs`, the final one will expose all the event log records through the `BCDD::Result#event_logs` method.

```ruby
class Division
  include BCDD::Result.mixin(config: { addon: { continue: true } })

  def call(arg1, arg2)
    BCDD::Result.event_logs(name: 'Division', desc: 'divide two numbers') do
      Given([arg1, arg2])
        .and_then(:require_numbers)
        .and_then(:check_for_zeros)
        .and_then(:divide)
    end
  end

  private

  ValidNumber = ->(arg) { arg.is_a?(Numeric) && (!arg.respond_to?(:finite?) || arg.finite?) }

  def require_numbers((arg1, arg2))
    ValidNumber[arg1] or return Failure(:invalid_arg, 'arg1 must be a valid number')
    ValidNumber[arg2] or return Failure(:invalid_arg, 'arg2 must be a valid number')

    Continue([arg1, arg2])
  end

  def check_for_zeros(numbers)
    num1, num2 = numbers

    return Failure(:division_by_zero, 'num2 cannot be zero') if num2.zero?

    num1.zero? ? Success(:division_completed, 0) : Continue(numbers)
  end

  def divide((num1, num2))
    Success(:division_completed, num1 / num2)
  end
end

module SumDivisionsByTwo
  extend self, BCDD::Result.mixin

  def call(*numbers)
    BCDD::Result.event_logs(name: 'SumDivisionsByTwo') do
      divisions = numbers.map { |number| Division.new.call(number, 2) }

      if divisions.any?(&:failure?)
        Failure(:errors, divisions.select(&:failure?).map(&:value))
      else
        Success(:sum, divisions.sum(&:value))
      end
    end
  end
end
```

Let's see the result of the `SumDivisionsByTwo` call:

```ruby
result = SumDivisionsByTwo.call(20, 10)
# => #<BCDD::Result::Success type=:sum value=15>

result.event_logs
{
  :version => 1,
  :metadata => {
    :duration => 0,   # milliseconds
    :trace_id => nil, # can be set through configuration
    :ids => {
      :tree => [0, [[1, []], [2, []]]],
      :matrix => { 0 => [0, 0], 1 => [1, 1], 2 => [2, 1]},
      :level_parent => { 0 => [0, 0], 1 => [1, 0], 2 => [1, 0]}
    }
  },
  :records=> [
    {
      :root => {:id=>0, :name=>"SumDivisionsByTwo", :desc=>nil},
      :parent => {:id=>0, :name=>"SumDivisionsByTwo", :desc=>nil},
      :current => {:id=>1, :name=>"Division", :desc=>"divide two numbers"},
      :result => {:kind=>:success, :type=>:_given_, :value=>[20, 2], :source=><Division:0x0000000102fd7ed0>},
      :and_then => {},
      :time => 2024-01-26 02:53:11.310346 UTC
    },
    {
      :root => {:id=>0, :name=>"SumDivisionsByTwo", :desc=>nil},
      :parent => {:id=>0, :name=>"SumDivisionsByTwo", :desc=>nil},
      :current => {:id=>1, :name=>"Division", :desc=>"divide two numbers"},
      :result => {:kind=>:success, :type=>:_continue_, :value=>[20, 2], :source=><Division:0x0000000102fd7ed0>},
      :and_then => {:type=>:method, :arg=>nil, :method_name=>:require_numbers},
      :time => 2024-01-26 02:53:11.310392 UTC
    },
    {
      :root => {:id=>0, :name=>"SumDivisionsByTwo", :desc=>nil},
      :parent => {:id=>0, :name=>"SumDivisionsByTwo", :desc=>nil},
      :current => {:id=>1, :name=>"Division", :desc=>"divide two numbers"},
      :result => {:kind=>:success, :type=>:_continue_, :value=>[20, 2], :source=><Division:0x0000000102fd7ed0>},
      :and_then => {:type=>:method, :arg=>nil, :method_name=>:check_for_zeros},
      :time=>2024-01-26 02:53:11.310403 UTC
    },
    {
      :root => {:id=>0, :name=>"SumDivisionsByTwo", :desc=>nil},
      :parent => {:id=>0, :name=>"SumDivisionsByTwo", :desc=>nil},
      :current => {:id=>1, :name=>"Division", :desc=>"divide two numbers"},
      :result => {:kind=>:success, :type=>:division_completed, :value=>10, :source=><Division:0x0000000102fd7ed0>},
      :and_then => {:type=>:method, :arg=>nil, :method_name=>:divide},
      :time => 2024-01-26 02:53:11.310409 UTC
    },
    {
      :root => {:id=>0, :name=>"SumDivisionsByTwo", :desc=>nil},
      :parent => {:id=>0, :name=>"SumDivisionsByTwo", :desc=>nil},
      :current => {:id=>2, :name=>"Division", :desc=>"divide two numbers"},
      :result => {:kind=>:success, :type=>:_given_, :value=>[10, 2], :source=><Division:0x0000000102fd6378>},
      :and_then => {},
      :time => 2024-01-26 02:53:11.310424 UTC
    },
    {
      :root => {:id=>0, :name=>"SumDivisionsByTwo", :desc=>nil},
      :parent => {:id=>0, :name=>"SumDivisionsByTwo", :desc=>nil},
      :current => {:id=>2, :name=>"Division", :desc=>"divide two numbers"},
      :result => {:kind=>:success, :type=>:_continue_, :value=>[10, 2], :source=><Division:0x0000000102fd6378>},
      :and_then => {:type=>:method, :arg=>nil, :method_name=>:require_numbers},
      :time => 2024-01-26 02:53:11.310428 UTC
    },
    {
      :root => {:id=>0, :name=>"SumDivisionsByTwo", :desc=>nil},
      :parent => {:id=>0, :name=>"SumDivisionsByTwo", :desc=>nil},
      :current => {:id=>2, :name=>"Division", :desc=>"divide two numbers"},
      :result => {:kind=>:success, :type=>:_continue_, :value=>[10, 2], :source=><Division:0x0000000102fd6378>},
      :and_then => {:type=>:method, :arg=>nil, :method_name=>:check_for_zeros},
      :time => 2024-01-26 02:53:11.310431 UTC
    },
    {
      :root => {:id=>0, :name=>"SumDivisionsByTwo", :desc=>nil},
      :parent => {:id=>0, :name=>"SumDivisionsByTwo", :desc=>nil},
      :current => {:id=>2, :name=>"Division", :desc=>"divide two numbers"},
      :result => {:kind=>:success, :type=>:division_completed, :value=>5, :source=><Division:0x0000000102fd6378>},
      :and_then => {:type=>:method, :arg=>nil, :method_name=>:divide},
      :time => 2024-01-26 02:53:11.310434 UTC
    },
    {
      :root => {:id=>0, :name=>"SumDivisionsByTwo", :desc=>nil},
      :parent => {:id=>0, :name=>"SumDivisionsByTwo", :desc=>nil},
      :current => {:id=>0, :name=>"SumDivisionsByTwo", :desc=>nil},
      :result => {:kind=>:success, :type=>:sum, :value=>15, :source=>SumDivisionsByTwo},
      :and_then => {},
      :time => 2024-01-26 02:53:11.310444 UTC
    }
  ]
}
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

### `metadata: {ids:}`

The `:ids` metadata property is a hash with three properties:
- `:tree`, a graph/tree representation of the id of each `event_logs` block.
- `:level_parent`, a hash with the level (depth) of each block and its parent id.
- `:matrix`, a matrix representation of the event logs ids. It is a simplification of the `:tree` property.

Use these data structures to build your own visualization.

> Check out [Event Logs Listener example](examples/single_listener/lib/single_event_logs_listener.rb) to see how a listener can be used to build a STDOUT visualization, using these properties.

```ruby
# tree:
# A graph representation (array of arrays) of the each event logs block id.
#
0                  # [0, [
|- 1               #   [1, [[2, []]]],
|  |- 2            #   [3, []],
|- 3               #   [4, [
|- 4               #     [5, []],
|  |- 5            #     [6, [[7, []]]]
|  |- 6            #   ]],
|     |- 7         #   [8, []]
|- 8               # ]]

# level_parent:
# The event logs ids are the keys, and the level (depth) and parent id the values.
                   # {
0                  #   0 => [0, 0],
|- 1               #   1 => [1, 0],
|  |- 2            #   2 => [2, 1],
|- 3               #   3 => [1, 0],
|- 4               #   4 => [1, 0],
|  |- 5            #   5 => [2, 4],
|  |- 6            #   6 => [2, 4],
|     |- 7         #   7 => [3, 6],
|- 8               #   8 => [1, 0]
                   # }

# matrix:
# The rows are the direct blocks from the root block,
# and the columns are the nested blocks from the direct ones.
                   # {
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

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

### Configuration

#### Turning on/off

You can use `BCDD::Result.config.feature.disable!(event_logs)` and `BCDD::Result.config.feature.enable!(event_logs)` to turn on/off the `BCDD::Result.event_logs` feature.

```ruby
BCDD::Result.configuration do |config|
  config.feature.disable!(event_logs)
end

result = SumDivisionsByTwo.call(20, 10)
# => #<BCDD::Result::Success type=:sum value=15>

result.event_logs
{
  :version=>1,
  :records=>[],
  :metadata=>{
    :duration=>0,
    :ids=>{:tree=>[], :matrix=>{}, :level_parent=>{}}, :trace_id=>nil
  }
}
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### Setting a `trace_id` fetcher

You can define a lambda (arity 0) to fetch the trace_id. This lambda will be called before the first event logs block and will be used to set the `:trace_id` in the `:metadata` property.

Use to correlate different or the same operation (executed multiple times).

```ruby
BCDD::Result.config.event_logs.trace_id = -> { Thread.current[:bcdd_result_event_logs_trace_id] }
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### Setting a `listener`

You can define a listener to be called during the event logs tracking (check out [this example](examples/single_listener/lib/single_event_logs_listener.rb)). It must be a class that includes `BCDD::Result::EventLogs::Listener`.

Use it to build your additional logic on top of the tracking. Examples:
  - Log the event  logs.
  - Perform the tracing.
  - Instrument the event logs (measure/report).
  - Build a visualization (Diagrams, using the `records:` + `metadata: {ids:}` properties).

After implementing your listener, you can set it to the `BCDD::Result.config.event_logs.listener=`:

```ruby
BCDD::Result.config.event_logs.listener = MyEventLogsListener
```

See the example below to understand how to implement one:

```ruby
class MyEventLogsListener
  include BCDD::Result::EventLogs::Listener

  # A listener will be initialized before the first event logs block, and it is discarded after the last one.
  def initialize
  end

  # This method will be called before each event logs block.
  # The parent block will be called first in the case of nested ones.
  #
  # @param scope: {:id=>1, :name=>"SomeOperation", :desc=>"Optional description"}
  def on_start(scope:)
  end

  # This method will wrap all the event logs in the same block.
  # It can be used to perform an instrumentation (measure/report).
  #
  # @param scope: {:id=>1, :name=>"SomeOperation", :desc=>"Optional description"}
  def around_event_logs(scope:)
    yield
  end

  # This method will wrap each and_then call.
  # It can be used to perform an instrumentation of the and_then calls.
  #
  # @param scope: {:id=>1, :name=>"SomeOperation", :desc=>"Optional description"}
  # @param and_then:
  #  {:type=>:block, :arg=>:some_injected_value}
  #  {:type=>:method, :arg=>:some_injected_value, :method_name=>:some_method_name}
  def around_and_then(scope:, and_then:)
    yield
  end

  # This method will be called after each result recording/tracking.
  #
  # @param record:
  # {
  #   :root => {:id=>0, :name=>"RootOperation", :desc=>nil},
  #   :parent => {:id=>0, :name=>"RootOperation", :desc=>nil},
  #   :current => {:id=>1, :name=>"SomeOperation", :desc=>nil},
  #   :result => {:kind=>:success, :type=>:_continue_, :value=>{some: :thing}, :source=><MyProcess:0x0000000102fd6378>},
  #   :and_then => {:type=>:method, :arg=>nil, :method_name=>:some_method},
  #   :time => 2024-01-26 02:53:11.310431 UTC
  # }
  def on_record(record:)
  end

  # This method will be called at the end of the event logs tracking.
  #
  # @param event_logs:
  # {
  #   :version => 1,
  #   :metadata => {
  #     :duration => 0,
  #     :trace_id => nil,
  #     :ids => {
  #       :tree => [0, [[1, []], [2, []]]],
  #       :matrix => { 0 => [0, 0], 1 => [1, 1], 2 => [2, 1]},
  #       :level_parent => { 0 => [0, 0], 1 => [1, 0], 2 => [1, 0]}
  #     }
  #   },
  #   :records => [
  #     # ...
  #   ]
  # }
  def on_finish(event_logs:)
  end

  # This method will be called when an exception is raised during the event logs tracking.
  #
  # @param exception: Exception
  # @param event_logs: Hash
  def before_interruption(exception:, event_logs:)
  end
end
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### Setting multiple `listeners`

You can use `BCDD::Result::EventLogs::Listeners[]` to creates a listener of listeners (check out [this example](examples/multiple_listeners/Rakefile)), which will be called in the order they were added.

**Attention:** It only allows one listener to handle `around_and_then` and another `around_event_logs` records.

> The example below defines different listeners to handle `around_and_then` and `around_event_logs,` but it is also possible to define a listener to handle both.

```ruby
class AroundAndThenListener
  include BCDD::Result::EventLogs::Listener

  # It must be a static/singleton method.
  def self.around_and_then?
    true
  end

  def around_and_then(scope:, and_then:)
    #...
  end
end

class AroundEventLogsListener
  include BCDD::Result::EventLogs::Listener

  # It must be a static/singleton method.
  def self.around_event_logs?
    true
  end

  def around_event_logs(scope:)
    #...
  end
end

class MyEventLogsListener
  include BCDD::Result::EventLogs::Listener
end
```

How to use it:

```ruby
# The listeners will be called in the order they were added.
BCDD::Result.config.event_logs.listener = BCDD::Result::EventLogs::Listeners[
  MyEventLogsListener,
  AroundAndThenListener,
  AroundEventLogsListener
]
```

> Check out [this example](examples/multiple_listeners) to see a listener to print the event logs and another to store them in the database.

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

## `BCDD::Result.configuration`

The `BCDD::Result.configuration` allows you to configure default behaviors for `BCDD::Result` and `BCDD::Context` through a configuration block. After using it, the configuration is frozen, ensuring the expected behaviors for your application.

> Note: You can use `BCDD::Result.configuration(freeze: false) {}` to avoid the freezing. This can be useful in tests. Please be sure to use it with caution.

```ruby
BCDD::Result.configuration do |config|
  config.addon.enable!(:given, :continue)

  config.constant_alias.enable!('Result', 'BCDD::Context')

  config.pattern_matching.disable!(:nil_as_valid_value_checking)

  # config.feature.disable!(:expectations) if ::Rails.env.production?
end
```

Use `disable!` to disable a feature and `enable!` to enable it.

Let's see what each configuration in the example above does:

### `config.addon.enable!(:given, :continue)` <!-- omit in toc -->

This configuration enables the `Continue()` method for `BCDD::Result.mixin`, `BCDD::Context.mixin`, `BCDD::Result::Expectation.mixin`, and `BCDD::Context::Expectation.mixin`. Link to documentations: [(1)](#add-ons) [(2)](#mixin-add-ons).

It is also enabling the `Given()` which is already enabled by default. Link to documentation: [(1)](#add-ons) [(2)](#mixin-add-ons).

### `config.constant_alias.enable!('Result', 'BCDD::Context')` <!-- omit in toc -->

This configuration make `Result` a constant alias for `BCDD::Result`, and `BCDD::Context` a constant alias for `BCDD::Context`.

Link to documentations:
- [Result alias](#bcddresult-versus-result)
- [Context aliases](#constant-aliases)

### `config.pattern_matching.disable!(:nil_as_valid_value_checking)` <!-- omit in toc -->

This configuration disables the `nil_as_valid_value_checking` for `BCDD::Result` and `BCDD::Context`. Link to [documentation](#pattern-matching-support).

### `config.feature.disable!(:expectations)` <!-- omit in toc -->

This configuration turns off the expectations for `BCDD::Result` and `BCDD::Context`. The expectations are helpful in development and test environments, but they can be disabled in production environments for performance gain.

PS: I'm using `::Rails.env.production?` to check the environment, but you can use any logic you want.

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

### `BCDD::Result.config`

The `BCDD::Result.config` allows you to access the current configuration.

#### **BCDD::Result.config.addon** <!-- omit in toc -->

```ruby
BCDD::Result.config.addon.enabled?(:continue)
BCDD::Result.config.addon.enabled?(:given)

BCDD::Result.config.addon.options
# {
#   :continue=>{
#     :enabled=>false,
#     :affects=>[
#       "BCDD::Result.mixin",
#       "BCDD::Context.mixin",
#       "BCDD::Result::Expectations.mixin",
#       "BCDD::Context::Expectations.mixin"
#     ]
#   },
#   :given=>{
#     :enabled=>true,
#     :affects=>[
#       "BCDD::Result.mixin",
#       "BCDD::Context.mixin",
#       "BCDD::Result::Expectations.mixin",
#       "BCDD::Context::Expectations.mixin"
#     ]
#   }
# }
```

#### **BCDD::Result.config.constant_alias** <!-- omit in toc -->

```ruby
BCDD::Result.config.constant_alias.enabled?('Result')
BCDD::Result.config.constant_alias.enabled?('Context')
BCDD::Result.config.constant_alias.enabled?('BCDD::Context')

BCDD::Result.config.constant_alias.options
# {
#   "Result"=>{:enabled=>false, :affects=>["Object"]},
#   "Context"=>{:enabled=>false, :affects=>["Object"]},
#   "BCDD::Context"=>{:enabled=>false, :affects=>["BCDD"]}
# }
```

#### **BCDD::Result.config.pattern_matching** <!-- omit in toc -->

```ruby
BCDD::Result.config.pattern_matching.enabled?(:nil_as_valid_value_checking)

BCDD::Result.config.pattern_matching.options
# {
#   :nil_as_valid_value_checking=>{
#     :enabled=>false,
#     :affects=>[
#       "BCDD::Result::Expectations,
#       "BCDD::Context::Expectations"
#     ]
#   }
# }
```

#### **BCDD::Result.config.feature** <!-- omit in toc -->

```ruby
BCDD::Result.config.feature.enabled?(:expectations)

BCDD::Result.config.feature.options
# {
#   :expectations=>{
#     :enabled=>true,
#     :affects=>[
#       "BCDD::Result::Expectations,
#       "BCDD::Context::Expectations"
#     ]
#   },
#   event_logs=>{
#     :enabled=>true,
#     :affects=>[
#       "BCDD::Result",
#       "BCDD::Context"
#     ]
#   },
#   :and_then!=>{
#     :enabled=>false,
#     :affects=>[
#       "BCDD::Result",
#       "BCDD::Context"
#     ]
#   },
# }
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

## `BCDD::Result#and_then!`

In the Ruby ecosystem, several gems facilitate operation composition using classes and modules. Two notable examples are the `interactor` gem and the `u-case` gem.

**`interactor` gem example**

```ruby
class PlaceOrder
  include Interactor::Organizer

  organize CreateOrder,
           PayOrder,
           SendOrderConfirmation,
           NotifyAdmins
end
```

**`u-case` gem example**

```ruby
class PlaceOrder < Micro::Case
  flow CreateOrder, PayOrder, SendOrderConfirmation, NotifyAdmins
end

# Alternative approach
class PlaceOrder < Micro::Case
  def call!
    call(CreateOrder)
      .then(PayOrder)
      .then(SendOrderConfirmation)
      .then(NotifyAdmins)
  end
end
```

To facilitate migration for users accustomed to the above approaches, `bcdd-result` includes the `BCDD::Result#and_then!`/`BCDD::Context#and_then!` methods, which will invoke the method `call` of the given operation and expect it to return a `BCDD::Result`/`BCDD::Context` object.

```ruby
BCDD::Result.configure do |config|
  config.feature.enable!(:and_then!)
end

class PlaceOrder
  include BCDD::Context.mixin

  def call(**input)
    Given(input)
      .and_then!(CreateOrder.new)
      .and_then!(PayOrder.new)
      .and_then!(SendOrderConfirmation.new)
      .and_then!(NotifyAdmins.new)
  end
end
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### Dependency Injection

Like `#and_then`, `#and_then!` also supports an additional argument for dependency injection.

**In BCDD::Result**

```ruby
class PlaceOrder
  include BCDD::Result.mixin

  def call(input, logger:)
    Given(input)
      .and_then!(CreateOrder.new, logger)
      # Further method chaining...
  end
end
```

**In BCDD::Context**

```ruby
class PlaceOrder
  include BCDD::Context.mixin

  def call(logger:, **input)
    Given(input)
      .and_then!(CreateOrder.new, logger:)
      # Further method chaining...
  end
end
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### Configuration

```ruby
BCDD::Result.configure do |config|
  config.feature.enable!(:and_then!)

  config.and_then!.default_method_name_to_call = :perform
end
```

**Explanation:**

- `enable!(:and_then!)`: Activates the `and_then!` feature.

- `default_method_name_to_call`: Sets a default method other than `:call` for `and_then!`.

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### Analysis: Why is `and_then!` an Anti-pattern?

The `and_then!` approach, despite its brevity, introduces several issues:

- **Lack of Clarity:** The input/output relationship between the steps is not apparent.

- **Steps Coupling:** Each operation becomes interdependent (high coupling), complicating implementation and compromising the reusability of these operations.

We recommend cautious use of `#and_then!`. Due to these issues, it is turned off by default and considered an antipattern.

It should be a temporary solution, primarily for assisting in migration from another to gem to `bcdd-result`.

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### `#and_then` versus `#and_then!`

The main difference between the `#and_then` and `#and_then!` is that the latter does not check the result source. However, as a drawback, the result source will change.

Attention: to ensure the correct behavior, do not mix `#and_then` and `#and_then!` in the same result chain.

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### Analysis: Why is `#and_then` the antidote/standard?

The `BCDD::Result#and_then`/`BCDD::Context#and_then` methods diverge from the above approach by requiring explicit invocation and mapping of the outcomes at each process step. This approach has the following advantages:

- **Clarity:** The input/output relationship between the steps is apparent and highly understandable.

- **Steps uncoupling:** Each operation becomes independent (low coupling). You can even map a failure result to a success (and vice versa).

See this example to understand what your code should look like:

```ruby
class PlaceOrder
  include BCDD::Context.mixin(config: { addon: { continue: true } })

  def call(**input)
    Given(input)
      .and_then(:create_order)
      .and_then(:pay_order)
      .and_then(:send_order_confirmation)
      .and_then(:notify_admins)
      .and_expose(:order_placed, %i[order])
  end

  private

  def create_order(customer:, products:)
    CreateOrder.new.call(customer:, products:).handle do |on|
      on.success { |output| Continue(order: output[:order]) }
      on.failure { |error| Failure(:order_creation_failed, error:) }
    end
  end

  def pay_order(customer:, order:, payment_method:, **)
    PayOrder.new.call(customer:, payment_method:, order:).handle do |on|
      on.success { |output| Continue(payment: output[:payment]) }
      on.failure { |error| Failure(:order_payment_failed, error:) }
    end
  end

  def send_order_confirmation(customer:, order:, payment:, **)
    SendOrderConfirmation.new.call(customer:, order:, payment:).handle do |on|
      on.success { Continue() }
      on.failure { |error| Failure(:order_confirmation_failed, error:) }
    end
  end

  def notify_admins(customer:, order:, payment:, **)
    NotifyAdmins.new.call(customer:, order:, payment:)

    Continue()
  end
end
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

## About

[Rodrigo Serradura](https://github.com/serradura) created this project. He is the B/CDD process/method creator and has already made similar gems like the [u-case](https://github.com/serradura/u-case) and [kind](https://github.com/serradura/kind/blob/main/lib/kind/result.rb). This gem can be used independently, but it also contains essential features that facilitate the adoption of B/CDD in code.

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
