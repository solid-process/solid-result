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
  - [Pattern Matching](#pattern-matching)
    - [`Array`/`Find` patterns](#arrayfind-patterns)
    - [`Hash` patterns](#hash-patterns)
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
  - [`BCDD::Result::Context`](#bcddresultcontext)
    - [Defining successes and failures](#defining-successes-and-failures)
    - [`BCDD::Result::Context.mixin`](#bcddresultcontextmixin)
      - [Class example (Instance Methods)](#class-example-instance-methods-1)
      - [`and_expose`](#and_expose)
      - [Module example (Singleton Methods)](#module-example-singleton-methods-1)
    - [`BCDD::Result::Context::Expectations`](#bcddresultcontextexpectations)
    - [Mixin add-ons](#mixin-add-ons)
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

Result hooks are methods that allow you to execute a block of code based on the type of result obtained.
To demonstrate their use, I will implement a function that can divide two numbers.

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
    .on_type(:invalid_arg) { |msg| puts msg }
    .on_type(:division_by_zero) { |msg| puts msg }
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
# It executes the block and return itself.

divide(4, 2).on_success { |number| puts number }

divide(4, 2).on_success(:division_completed) { |number| puts number }

# It doesn't execute the block, but return itself.

divide(4, 4).on_success(:ok) { |value| puts value }

divide(4, 4).on_failure { |error| puts error }
```

*PS: The `divide()` implementation is [here](#result-hooks).*

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### `result.on_failure`

It is the opposite of `Result#on_success`:

1. It will only execute the block of code if the result is a failure.
2. If the type declaration is not included, the method will execute the block for any failed result, regardless of its type.

```ruby
# It executes the block and return itself.

divide(nil, 2).on_failure { |error| puts error }

divide(4, 0).on_failure(:invalid_arg, :division_by_zero) { |error| puts error }

# It doesn't execute the block, but return itself.

divide(4, 0).on_success { |number| puts number }

divide(4, 0).on_failure(:invalid_arg) { |error| puts error }
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

#### `BCDD::Result.mixin`

This method generates a module that can be included or extended by any object. It adds two methods to the target object: `Success()` and `Failure()`. The main difference between these methods and `BCDD::Result::Success()`/`BCDD::Result::Failure()` is that the former will utilize the target object (which has received the include/extend) as the result's subject.

As a result, you can utilize the `#and_then` method to invoke methods from the result's subject.

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
  extend self, BCDD::Result.mixin

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

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

##### Important Requirement

To use the `#and_then` method to call methods, they must use `Success()` and `Failure()` to produce the results.

If you try to use `BCDD::Result::Subject()`/`BCDD::Result::Failure()`, or results from another `BCDD::Result.mixin` instance with `#and_then`, it will raise an error because the subjects will be different.

**Note:** You can still use the block syntax, but all the results must be produced by the subject's `Success()` and `Failure()` methods.

```ruby
module ValidateNonZero
  extend self, BCDD::Result.mixin

  def call(numbers)
    return Success(:ok, numbers) unless numbers.last.zero?

    Failure(:division_by_zero, 'arg2 must not be zero')
  end
end

class Divide
  include BCDD::Result.mixin

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
    arg1.is_a?(::Numeric) or return BCDD::Result::Failure(:invalid_arg, 'arg1 must be numeric') # This will raise an error
    arg2.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg2 must be numeric')

    BCDD::Result::Success(:ok, [arg1, arg2]) # This will raise an error
  end

  def validate_non_zero(numbers)
    ValidateNonZero.call(numbers) # This will raise an error

    # This would work:
    # In this case we are handling the other subject result and returning our own
    # ValidateNonZero.call(numbers).handle do |on|
    #   on.success { |numbers| Success(:ok, numbers) }
    #   on.failure { |err| Failure(:division_by_zero, err) }
    # end
  end

  def divide((number1, number2))
    Success(:division_completed, number1 / number2)
  end
end
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

##### Dependency Injection

The `BCDD::Result#and_then` accepts a second argument that will be used to share a value with the subject's method. To receive this argument, the subject's method must have an arity of two, where the first argument will be the result value and the second will be the shared value.

```ruby
require 'logger'

module Divide
  extend self, BCDD::Result.mixin

  def call(arg1, arg2, logger: ::Logger.new(STDOUT))
    validate_numbers(arg1, arg2)
      .and_then(:validate_non_zero, logger)
      .and_then(:divide, logger)
  end

  private

  def validate_numbers(arg1, arg2)
    arg1.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg2 must be numeric')

    Success(:ok, [arg1, arg2])
  end

  def validate_non_zero(numbers, logger)
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

The `BCDD::Result.mixin` also accepts the `with:` argument. It is a hash that will be used to define the methods that will be added to the target object.

**Continue**

This addon will create the `Continue(value)` method, which will know how to produce a `Success(:continued, value)`. It is useful when you want to perform a sequence of operations but want to avoid returning a specific result for each step.

```ruby
module Divide
  extend self, BCDD::Result.mixin(config: :continue)

  def call(arg1, arg2)
    validate_numbers(arg1, arg2)
      .and_then(:validate_non_zero)
      .and_then(:divide)
  end

  private

  def validate_numbers(arg1, arg2)
    arg1.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg2 must be numeric')

    Continue([arg1, arg2])
  end

  def validate_non_zero(numbers)
    return Continue(numbers) unless numbers.last.zero?

    Failure(:division_by_zero, 'arg2 must not be zero')
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

In the code above, we define a constant `Divide::Expected`. And because of this (it is a constant), we can use it inside and outside the module.

Look what happens if you try to create a result without one of the expected types.

```ruby
Divide::Result::Success(:ok)
# type :ok is not allowed. Allowed types: :numbers, :division_completed
# (BCDD::Result::Expectations::Error::UnexpectedType)

Divide::Result::Failure(:err)
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

If you use `#on` or `#on_type` to execute a block, `BCDD::Result::Expectations` will check whether the result type is valid/expected. Otherwise, an error will be raised.

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
# type :ok is not allowed. Allowed types: :numbers, :division_completed (BCDD::Result::Expectations::Error::UnexpectedType)

Divide::Result::Success(:numbers, [1])
# value [1] is not allowed for :numbers type (BCDD::Result::Expectations::Error::UnexpectedValue)

Divide::Result::Success(:division_completed, '2')
# value "2" is not allowed for :division_completed type (BCDD::Result::Expectations::Error::UnexpectedValue)
```

##### Failure()

```ruby
Divide::Result::Failure(:err)
# type :err is not allowed. Allowed types: :invalid_arg, :division_by_zero (BCDD::Result::Expectations::Error::UnexpectedType)

Divide::Result::Failure(:invalid_arg, :arg1_must_be_numeric)
# value :arg1_must_be_numeric is not allowed for :invalid_arg type (BCDD::Result::Expectations::Error::UnexpectedValue)

Divide::Result::Failure(:division_by_zero, msg: 'arg2 must not be zero')
# value {:msg=>"arg2 must not be zero"} is not allowed for :division_by_zero type (BCDD::Result::Expectations::Error::UnexpectedValue)
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

##### Pattern Matching Support

The value checking has support for handling pattern-matching errors, and the cleanest way to do it is using the one-line pattern matching operators (`=>` since Ruby 3.0) and (`in` Ruby 2.7).

How does this operator work? They raise an error when the pattern does not match but returns nil when it matches.

Because of this, you will need to enable `nil` as a valid value checking. You can do it by calling the `BCDD::Result::Contract.nil_as_valid_value_checking!` method.

**Attention:**

If you decide to enable this, you will do it at the beginning of your code or in an initializer. And remember, this will affect all kinds of result expectations (`BCDD::Result::Expectations` and `BCDD::Result::Context::Expectations`). So, it is recommended to use it only when you are using pattern matching for **ALL** the result's value validations.

```ruby
#
# Put this line in an initializer or at the beginning of your code.
# It is required if you decide to use pattern matching to validate all of your result's values.
#
BCDD::Result::Contract.nil_as_valid_value_checking!

module Divide
  extend BCDD::Result::Expectations.mixin(
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
# value "5" is not allowed for :division_completed type ("5": Float === "5" does not return true) (BCDD::Result::Contract::Error::UnexpectedValue)
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### `BCDD::Result::Expectations.mixin` add-ons

The `BCDD::Result::Expectations.mixin` also accepts the `with:` argument. It is a hash that will be used to define the methods that will be added to the target object.

**Continue**

It is similar to `BCDD::Result.mixin(config: :continue)`, the key difference is that the `Continue(value)` will be ignored by the expectations. This is extremely useful when you want to use `Continue(value)` to chain operations, but you don't want to declare N success types in the expectations.

```ruby
class Divide
  include BCDD::Result::Expectations.mixin(
    config: :continue,
    success: :division_completed,
    failure: %i[invalid_arg division_by_zero]
  )

  def call(arg1, arg2)
    validate_numbers(arg1, arg2)
      .and_then(:validate_non_zero)
      .and_then(:divide)
  end

  private

  def validate_numbers(arg1, arg2)
    arg1.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg2 must be numeric')

    Continue([arg1, arg2])
  end

  def validate_non_zero(numbers)
    return Continue(numbers) unless numbers.last.zero?

    Failure(:division_by_zero, 'arg2 must not be zero')
  end

  def divide((number1, number2))
    Success(:division_completed, number1 / number2)
  end
end

result = Divide.new.call(4,2)
# => #<BCDD::Result::Success type=:division_completed value=2>

# The example below shows an error because the :ok type is not allowed.
# But look at the allowed types have only one type (:division_completed).
# This is because the :continued type is ignored by the expectations.
#
result.success?(:ok)
# type :ok is not allowed. Allowed types: :division_completed (BCDD::Result::Expectations::Error::UnexpectedType)
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

### `BCDD::Result::Context`

The `BCDD::Result::Context` is a `BCDD::Result`, meaning it has all the features of the `BCDD::Result`. The main difference is that it only accepts keyword arguments as a value, which applies to the `and_then`: The called methods must receive keyword arguments, and the dependency injection will be performed through keyword arguments.

As the input/output are hashes, the results of each `and_then` call will automatically accumulate. This is useful in operations chaining, as the result of the previous operations will be automatically available for the next one. Because of this behavior, the `BCDD::Result::Context` has the `#and_expose` method to expose only the desired keys from the accumulated result.

#### Defining successes and failures

As the `BCDD::Result`, you can declare success and failures directly from `BCDD::Result::Context`.

```ruby
BCDD::Result::Context::Success(:ok, a: 1, b: 2)
#<BCDD::Result::Context::Success type=:ok value={:a=>1, :b=>2}>

BCDD::Result::Context::Failure(:err, message: 'something went wrong')
#<BCDD::Result::Context::Failure type=:err value={:message=>"something went wrong"}>
```

But different from `BCDD::Result` that accepts any value, the `BCDD::Result::Context` only takes keyword arguments.

```ruby
BCDD::Result::Context::Success(:ok, [1, 2])
# wrong number of arguments (given 2, expected 1) (ArgumentError)

BCDD::Result::Context::Failure(:err, { message: 'something went wrong' })
# wrong number of arguments (given 2, expected 1) (ArgumentError)

#
# Use ** to convert a hash to keyword arguments
#
BCDD::Result::Context::Success(:ok, **{ message: 'hashes can be converted to keyword arguments' })
#<BCDD::Result::Context::Success type=:ok value={:message=>"hashes can be converted to keyword arguments"}>
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### `BCDD::Result::Context.mixin`

As in the `BCDD::Result`, you can use the `BCDD::Result::Context.mixin` to add the `Success()` and `Failure()` methods to your classes/modules.

Let's see this feature and the data accumulation in action:

##### Class example (Instance Methods)

```ruby
class Divide
  require 'logger'

  include BCDD::Result::Context.mixin

  def call(arg1, arg2, logger: ::Logger.new(STDOUT))
    validate_numbers(arg1, arg2)
      .and_then(:validate_non_zero)
      .and_then(:divide, logger: logger)
  end

  private

  def validate_numbers(arg1, arg2)
    arg1.is_a?(::Numeric) or return Failure(:err, message: 'arg1 must be numeric')
    arg2.is_a?(::Numeric) or return Failure(:err, message: 'arg2 must be numeric')

    Success(:ok, number1: arg1, number2: arg2)
  end

  def validate_non_zero(number2:, **)
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
#<BCDD::Result::Context::Success type=:ok value={:number=>2}>

Divide.new.call('10', 5)
#<BCDD::Result::Context::Failure type=:err value={:message=>"arg1 must be numeric"}>

Divide.new.call(10, '5')
#<BCDD::Result::Context::Failure type=:err value={:message=>"arg2 must be numeric"}>

Divide.new.call(10, 0)
#<BCDD::Result::Context::Failure type=:err value={:message=>"arg2 must not be zero"}>
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

##### `and_expose`

This allows you to expose only the desired keys from the accumulated result. It can be used with any `BCDD::Result::Context` object.

Let's add it to the previous example:

```ruby
class Divide
  include BCDD::Result::Context.mixin

  def call(arg1, arg2)
    validate_numbers(arg1, arg2)
      .and_then(:validate_non_zero)
      .and_then(:divide)
  end

  private

  def validate_numbers(arg1, arg2)
    arg1.is_a?(::Numeric) or return Failure(:err, message: 'arg1 must be numeric')
    arg2.is_a?(::Numeric) or return Failure(:err, message: 'arg2 must be numeric')

    Success(:ok, number1: arg1, number2: arg2)
  end

  def validate_non_zero(number2:, **)
    return Success(:ok) if number2.nonzero?

    Failure(:err, message: 'arg2 must not be zero')
  end

  def divide(**input)
    Success(:ok, number: input.values.reduce(:/), **input)
  end
end

Divide.new.call(10, 5)
#<BCDD::Result::Context::Success type=:division_completed value={:number=>2}>
```

As you can see, even with `divide` success exposing the division number with all the accumulated data (`**input`), the `#and_expose` could generate a new success with a new type and only with the desired keys.

Remove the `#and_expose` call to see the difference. This will be the outcome:

```ruby
Divide.new.call(10, 5)
#<BCDD::Result::Context::Success type=:ok value={:number=>2, :number1=>10, :number2=>5}>
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

##### Module example (Singleton Methods)

Yes, the `BCDD::Result::Context.mixin` can produce singleton methods. Look for an example using a module (but it could be a class, too).

```ruby
module Divide
  extend self, BCDD::Result::Context.mixin

  def call(arg1, arg2)
    validate_numbers(arg1, arg2)
      .and_then(:validate_non_zero)
      .and_then(:divide)
      .and_expose(:division_completed, [:number])
  end

  private

  def validate_numbers(arg1, arg2)
    arg1.is_a?(::Numeric) or return Failure(:err, message: 'arg1 must be numeric')
    arg2.is_a?(::Numeric) or return Failure(:err, message: 'arg2 must be numeric')

    Success(:ok, number1: arg1, number2: arg2)
  end

  def validate_non_zero(number2:, **)
    return Success(:ok) if number2.nonzero?

    Failure(:err, message: 'arg2 must not be zero')
  end

  def divide(number1:, number2:)
    Success(:ok, number: number1 / number2)
  end
end

Divide.call(10, 5)
#<BCDD::Result::Context::Success type=:division_completed value={:number=>2}>

Divide.call('10', 5)
#<BCDD::Result::Context::Failure type=:err value={:message=>"arg1 must be numeric"}>

Divide.call(10, '5')
#<BCDD::Result::Context::Failure type=:err value={:message=>"arg2 must be numeric"}>

Divide.call(10, 0)
#<BCDD::Result::Context::Failure type=:err value={:message=>"arg2 must not be zero"}>
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### `BCDD::Result::Context::Expectations`

The `BCDD::Result::Context::Expectations` is a `BCDD::Result::Expectations` with the `BCDD::Result::Context` features.

This is an example using the mixin mode, but the standalone mode is also supported.

```ruby
#
# Put this line in an initializer or at the beginning of your code.
# It is required if you decide to use pattern matching to validate all of your result's values.
#
BCDD::Result::Contract.nil_as_valid_value_checking!

class Divide
  include BCDD::Result::Context::Expectations.mixin(
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

    Success(:division_completed, number: arg1 / arg2)
  end
end

Divide.new.call(10, 5)
#<BCDD::Result::Context::Success type=:division_completed value={:number=>2}>
```

As in the `BCDD::Result::Expectations.mixin`, the `BCDD::Result::Context::Expectations.mixin` will add a Result constant in the target class. It can generate success/failure results, which ensure the mixin expectations.

Let's see this using previous example:

```ruby
Divide::Result::Success(:division_completed, number: 2)
#<BCDD::Result::Context::Success type=:division_completed value={:number=>2}>

Divide::Result::Success(:division_completed, number: '2')
# value {:number=>"2"} is not allowed for :division_completed type ({:number=>"2"}: Numeric === "2" does not return true) (BCDD::Result::Contract::Error::UnexpectedValue)
```

<p align="right"><a href="#-bcddresult">⬆️ &nbsp;back to top</a></p>

#### Mixin add-ons

The `BCDD::Result::Context.mixin` and `BCDD::Result::Context::Expectations.mixin` also accepts the `with:` argument. And it works the same way as the `BCDD::Result` mixins.

**Continue**

The `BCDD::Result::Context.mixin(config: :continue)` or `BCDD::Result::Context::Expectations.mixin(config: :continue)` adds a `Continue(**input)` that will be ignored by the expectations. This is extremely useful when you want to use `Continue()` to chain operations, but you don't want to declare N success types in the expectations.

Let's use a mix of `BCDD::Result::Context` features to see in action with this add-on:

```ruby
#
# Put this line in an initializer or at the beginning of your code.
# It is required if you decide to use pattern matching to validate all of your result's values.
#
BCDD::Result::Contract.nil_as_valid_value_checking!

module Divide
  require 'logger'

  extend self, BCDD::Result::Context::Expectations.mixin(
    config: :continue,
    success: {
      division_completed: ->(value) { value => { number: Numeric } }
    },
    failure: {
      invalid_arg:      ->(value) { value => { message: String } },
      division_by_zero: ->(value) { value => { message: String } }
    }
  )

  def call(arg1, arg2, logger: ::Logger.new(STDOUT))
    validate_numbers(arg1, arg2)
      .and_then(:validate_non_zero)
      .and_then(:divide, logger: logger)
      .and_expose(:division_completed, [:number])
  end

  private

  def validate_numbers(arg1, arg2)
    arg1.is_a?(::Numeric) or return Failure(:invalid_arg, message: 'arg1 must be numeric')
    arg2.is_a?(::Numeric) or return Failure(:invalid_arg, message: 'arg2 must be numeric')

    Continue(number1: arg1, number2: arg2)
  end

  def validate_non_zero(number2:, **)
    return Continue() if number2.nonzero?

    Failure(:division_by_zero, message: 'arg2 must not be zero')
  end

  def divide(number1:, number2:, logger:)
    result = number1 / number2

    logger.info("The division result is #{result}")

    Continue(number: result)
  end
end

Divide.call(14, 2)
# I, [2023-10-27T02:01:05.812388 #77823]  INFO -- : The division result is 7
#<BCDD::Result::Context::Success type=:division_completed value={:number=>7}>

Divide.call('14', 2)
#<BCDD::Result::Context::Failure type=:invalid_arg value={:message=>"arg1 must be numeric"}>

Divide.call(14, '2')
#<BCDD::Result::Context::Failure type=:invalid_arg value={:message=>"arg2 must be numeric"}>

Divide.call(14, 0)
#<BCDD::Result::Context::Failure type=:division_by_zero value={:message=>"arg2 must not be zero"}>
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
