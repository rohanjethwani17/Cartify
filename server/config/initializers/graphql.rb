# GraphQL configuration

# Enable GraphQL-Ruby tracing in development
if Rails.env.development?
  GraphQL::Tracing::PlatformTracing.new
end
