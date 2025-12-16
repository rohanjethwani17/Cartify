# Cartify Server

Ruby on Rails GraphQL API for Cartify - a multi-tenant commerce operations platform.

## Architecture

```
server/
├── app/
│   ├── channels/          # ActionCable channels for WebSocket subscriptions
│   ├── controllers/       # GraphQL controller
│   ├── graphql/
│   │   ├── mutations/     # GraphQL mutations
│   │   ├── sources/       # Dataloader sources (N+1 prevention)
│   │   └── types/         # GraphQL types
│   ├── jobs/              # Sidekiq background jobs
│   ├── models/            # ActiveRecord models
│   ├── policies/          # Authorization policies (RBAC)
│   └── services/          # Service objects for business logic
├── config/
├── db/
│   └── migrate/           # Database migrations
└── spec/                  # RSpec tests
```

## GraphQL Batching Approach

We use `graphql-ruby`'s built-in Dataloader to prevent N+1 queries:

```ruby
# app/graphql/sources/record_source.rb
class RecordSource < GraphQL::Dataloader::Source
  def fetch(ids)
    records = @model_class.where(id: ids).index_by(&:id)
    ids.map { |id| records[id] }
  end
end

# Usage in types:
def product
  dataloader.with(Sources::RecordSource, Product).load(object.product_id)
end
```

## Subscription Flow

1. **Client connects** via WebSocket to `/cable` with JWT token
2. **Client subscribes** to a GraphQL subscription via `GraphqlChannel`
3. **Mutation/Job runs** and calls `CartifySchema.subscriptions.trigger(...)`
4. **Redis pub/sub** broadcasts to all connected clients
5. **ActionCable delivers** the payload to subscribed clients

```
Client ──ws──> ActionCable ──> GraphqlChannel ──> CartifySchema
                   │
                   └── Redis Pub/Sub <── Mutation/Job triggers
```

## Query Protection

- **Max Depth**: 15 levels
- **Max Complexity**: 300 points
- **Default Page Size**: 50 items

## Commands

```bash
# Install dependencies
bundle install

# Setup database
bundle exec rails db:prepare

# Run server
bundle exec rails server

# Run Sidekiq
bundle exec sidekiq

# Run tests
bundle exec rspec

# Generate demo data
bundle exec rails runner "GenerateDemoDataJob.perform_now(Store.first.id)"
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|--------|
| DATABASE_URL | PostgreSQL connection string | - |
| REDIS_URL | Redis connection string | redis://localhost:6379/0 |
| SECRET_KEY_BASE | Rails secret key | - |
| ACTION_CABLE_URL | WebSocket URL for clients | ws://localhost:3000/cable |

## API Authentication

Use JWT tokens in the `Authorization` header:

```
Authorization: Bearer <token>
```

Obtain tokens via the `signIn` mutation:

```graphql
mutation {
  signIn(email: "demo@cartify.dev", password: "password123") {
    token
    user {
      id
      email
    }
  }
}
```

## Tradeoffs & Next Steps

### Current Tradeoffs
- Session-less JWT auth (tokens can't be revoked server-side)
- Synchronous audit logging (could be moved to background)
- In-memory GraphQL subscriptions cache (fine for single-server)

### Next Steps
- Add GraphQL introspection caching
- Implement cursor-based pagination with total counts optimization
- Add rate limiting per user/store
- Implement webhook delivery for external integrations
- Add GraphQL persisted queries for production
