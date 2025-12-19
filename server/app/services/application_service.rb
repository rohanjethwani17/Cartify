class ApplicationService
  def self.call(...)
    new(...).call
  end

  def initialize
    @errors = []
  end

  def call
    raise NotImplementedError
  end

  protected

  attr_reader :errors

  def success(data = nil)
    ServiceResult.new(success: true, data: data, errors: [])
  end

  def failure(errors = nil)
    ServiceResult.new(success: false, data: nil, errors: Array(errors || @errors))
  end
end

class ServiceResult
  attr_reader :data, :errors

  def initialize(success:, data:, errors:)
    @success = success
    @data = data
    @errors = errors
  end

  def success?
    @success
  end

  def failure?
    !@success
  end
end
