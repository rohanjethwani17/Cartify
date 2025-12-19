# GraphQL configuration

# Enable GraphQL-Ruby tracing in development
GraphQL::Tracing::PlatformTracing.new if Rails.env.development?
