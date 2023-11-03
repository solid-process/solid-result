# frozen_string_literal: true

module BCDD::Result::Failure::Methods
  def success?(_type = nil)
    false
  end

  def failure?(type = nil)
    type.nil? || type_checker.allow_failure?([type])
  end

  def value_or
    yield(value)
  end

  def end_line?
    true
  end

  private

  def name
    :failure
  end
end
