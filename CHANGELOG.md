## [Unreleased]

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
