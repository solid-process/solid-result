# BCDD::Result <!-- omit in toc -->

A general-purpose result monad that allows you to create objects that represent a success (`BCDD::Result::Success`) or failure (`BCDD::Result::Failure`).

**What problem does it solve?**

It allows you to consistently represent the concept of success and failure throughout your codebase.

Furthermore, this abstraction exposes several methods that will be useful to make the code flow react clearly and cleanly to the result represented by these objects.

- [Installation](#installation)
- [Usage](#usage)
- [Reference](#reference)
  - [Result Attributes](#result-attributes)
    - [Receiving types in `result.success?` or `result.failure?`](#receiving-types-in-resultsuccess-or-resultfailure)
  - [Result Hooks](#result-hooks)
    - [`result.on`](#resulton)
    - [`result.on_type`](#resulton_type)
    - [`result.on_success`](#resulton_success)
    - [`result.on_failure`](#resulton_failure)
  - [Result value](#result-value)
    - [`result.value_or`](#resultvalue_or)
    - [`result.data_or`](#resultdata_or)
  - [Railway Oriented Programming](#railway-oriented-programming)
    - [`result.and_then`](#resultand_then)
- [About](#about)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)


## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add bcdd-result

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install bcdd-result

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

<p align="right">(<a href="#bcddresult-">⬆️ &nbsp;back to top</a>)</p>

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

<p align="right">(<a href="#bcddresult-">⬆️ &nbsp;back to top</a>)</p>

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

<p align="right">(<a href="#bcddresult-">⬆️ &nbsp;back to top</a>)</p>

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

<p align="right">(<a href="#bcddresult-">⬆️ &nbsp;back to top</a>)</p>

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

<p align="right">(<a href="#bcddresult-">⬆️ &nbsp;back to top</a>)</p>

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

<p align="right">(<a href="#bcddresult-">⬆️ &nbsp;back to top</a>)</p>

### Result value

The most simple way to get the result value is by calling `BCDD::Result#value` or `BCDD::Result#data`.

But sometimes you need to get the value of a successful result or a default value if it is a failure. In this case, you can use `BCDD::Result#value_or` or `BCDD::Result#data_or`.

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

<p align="right">(<a href="#bcddresult-">⬆️ &nbsp;back to top</a>)</p>

#### `result.data_or`

`BCDD::Result#data_or` is an alias of `BCDD::Result#value_or`.


### Railway Oriented Programming

#### `result.and_then`

This feature/pattern is also known as ["Railway Oriented Programming"](https://fsharpforfunandprofit.com/rop/).

The idea is to chain blocks and creates a pipeline of operations that can be interrupted by a failure.

In other words, the block will be executed only if the result is a success.
So, if some block returns a failure, the following blocks will be skipped.

Due to this characteristic, you can use this feature to express some logic as a sequence of operations. And have the guarantee that the process will stop by the first failure detection, and if everything is ok, the final result will be a success. e.g.,

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

    BCDD::Result::Failure(:division_by_zero, "arg2 must not be zero")
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

<p align="right">(<a href="#bcddresult-">⬆️ &nbsp;back to top</a>)</p>

## About

[Rodrigo Serradura](https://github.com/serradura) created this project. He is the B/CDD process/method creator and has already made similar gems like the [u-case](https://github.com/serradura/u-case) and [kind](https://github.com/serradura/kind/blob/main/lib/kind/result.rb). This gem is a general-purpose abstraction/monad, but it also contains key features that serve as facilitators for adopting B/CDD in the code.

<p align="right">(<a href="#bcddresult-">⬆️ &nbsp;back to top</a>)</p>

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rake` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

<p align="right">(<a href="#bcddresult-">⬆️ &nbsp;back to top</a>)</p>

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/B-CDD/bcdd-result. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/B-CDD/bcdd-result/blob/master/CODE_OF_CONDUCT.md).

<p align="right">(<a href="#bcddresult-">⬆️ &nbsp;back to top</a>)</p>

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

<p align="right">(<a href="#bcddresult-">⬆️ &nbsp;back to top</a>)</p>

## Code of Conduct

Everyone interacting in the BCDD::Result project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/B-CDD/bcdd-result/blob/master/CODE_OF_CONDUCT.md).
