Rails.application.routes.draw do
  # Health check
  get '/health', to: proc { [200, {}, ['OK']] }
  
  # GraphQL endpoint
  post '/graphql', to: 'graphql#execute'
  
  # GraphiQL in development
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql'
  end
  
  # ActionCable mount point for WebSocket connections
  mount ActionCable.server => '/cable'
end
