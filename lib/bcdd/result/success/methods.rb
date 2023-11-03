# frozen_string_literal: true

module BCDD::Result::Success::Methods
  def success?(type = nil)
    type.nil? || type_checker.allow_success?([type])
  end

  def failure?(_type = nil)
    false
  end

  def value_or
    value
  end

  def and_then(...)
    result = super

    if type == BCDD::Result::CONTINUED && result.success? && result.type != BCDD::Result::CONTINUED
      result.end_line = true
    end

    result
  end

  def end_line?
    !!end_line
  end

  private

  def name
    :success
  end
end
