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

  private

  def name
    :success
  end
end
