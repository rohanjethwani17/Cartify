Rails.application.routes.draw do
  # Health check
  get '/health', to: proc { [200, {}, ['OK']] }

  # GraphQL endpoint
  post '/graphql', to: 'graphql#execute'

  # GraphiQL in development
  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql' if Rails.env.development?

  # ActionCable mount point for WebSocket connections
  mount ActionCable.server => '/cable'
end
