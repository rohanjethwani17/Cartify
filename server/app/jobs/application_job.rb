class ApplicationJob < ActiveJob::Base
  # Retry failed jobs
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  # Discard jobs that fail permanently
  discard_on ActiveJob::DeserializationError
end
