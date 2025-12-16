# Cartify

A multi-tenant commerce operations platform (mini Shopify backend + admin) built with Ruby on Rails, GraphQL, React, and TypeScript.

## Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                         React Frontend                         │
│        (TypeScript + Apollo Client + graphql-ws)                │
└──────────────────────────────┬─────────────────────────────────┘
                               │
              ┌────────────────┴────────────────┐
              │   HTTP (Queries/Mutations)   │
              │   WebSocket (Subscriptions)  │
              └────────────────┬────────────────┘
                               │
┌──────────────────────────────┴─────────────────────────────────┐
│                     Rails API Server                            │
│  ┌───────────────────┐  ┌─────────────────────┐                 │
│  │ GraphQL Schema    │  │ ActionCable         │                 │
│  │ (graphql-ruby)    │  │ (WebSockets)        │                 │
│  └───────────────────┘  └─────────────────────┘                 │
│  ┌───────────────────┐  ┌─────────────────────┐                 │
│  │ Service Objects   │  │ Sidekiq Workers     │                 │
│  │ (Business Logic)  │  │ (Background Jobs)   │                 │
│  └───────────────────┘  └─────────────────────┘                 │
└───────────────┬───────────────┬─────────────────────────────────┘
                │               │
        ┌───────┴───────┐ ┌─────┴──────┐
        │   PostgreSQL  │ │    Redis   │
        │   (Database)  │ │ (Pub/Sub + │
        │               │ │  Queues)   │
        └───────────────┘ └────────────┘
```

## Tech Stack

| Layer | Technology |
|-------|------------|
| Backend | Ruby on Rails 7.1 (API mode) |
| GraphQL | graphql-ruby 2.1 |
| Subscriptions | ActionCable + Redis adapter |
| Database | PostgreSQL 15 |
| Cache/Queue | Redis 7 + Sidekiq 7 |
| Frontend | React 18 + TypeScript 5 |
| GraphQL Client | Apollo Client 3.8 |
| WS Protocol | graphql-ws |
| Type Safety | GraphQL Code Generator |
| Styling | Tailwind CSS 3 |
| Testing | RSpec (backend) + Vitest (frontend) |
| CI | GitHub Actions |

## Quick Start

### Prerequisites
- Docker & Docker Compose
- (Optional) Node.js 20+ and Ruby 3.2+ for local development

### 1. Clone and start services

```bash
git clone <repo-url>
cd cartify

# Start all services
docker compose up -d

# Wait for services to be healthy
docker compose ps
```

### 2. Seed demo data

```bash
# Run migrations and seed
docker compose exec server rails db:seed
```

### 3. Access the app

- **Frontend**: http://localhost:5173
- **GraphQL Playground**: http://localhost:3000/graphiql
- **Sidekiq Dashboard**: http://localhost:3000/sidekiq (development only)

### 4. Login

Use the demo credentials:
- Email: `demo@cartify.dev`
- Password: `password123`

## GraphQL Subscriptions

### How it works

1. **Client connects** via WebSocket to `/cable` with JWT token in params
2. **Client subscribes** through `GraphqlChannel` using `graphql-ws` protocol
3. **Server triggers** subscriptions from mutations or background jobs
4. **Redis pub/sub** broadcasts events to all ActionCable connections
5. **ActionCable delivers** payloads to subscribed clients

### Available Subscriptions

```graphql
# New order notification
subscription {
  orderCreated(storeId: "...") {
    id
    orderNumber
    totalPrice
  }
}

# Low inventory alert
subscription {
  inventoryLow(storeId: "...", threshold: 10) {
    id
    variant { displayName }
    currentLevel
  }
}

# Order fulfillment updates
subscription {
  fulfillmentStatusChanged(orderId: "...") {
    id
    fulfillmentStatus
  }
}

# Background job progress
subscription {
  syncProgressUpdated(storeId: "...") {
    progress
    total
    message
  }
}
```

## GraphQL Batching (N+1 Prevention)

We use graphql-ruby's built-in Dataloader:

```ruby
# app/graphql/sources/record_source.rb
class RecordSource < GraphQL::Dataloader::Source
  def fetch(ids)
    records = @model_class.where(id: ids).index_by(&:id)
    ids.map { |id| records[id] }
  end
end

# Usage in types
def product
  dataloader.with(Sources::RecordSource, Product).load(object.product_id)
end
```

## RBAC (Role-Based Access Control)

Three roles per store:
- **owner**: Full access, can manage settings and delete
- **staff**: Can create/update products, orders, inventory
- **read_only**: Can only view data

Implemented via policy objects:

```ruby
# app/policies/product_policy.rb
class ProductPolicy < ApplicationPolicy
  def create?
    can_write?
  end
  
  def destroy?
    owner? && belongs_to_store?
  end
end
```

## Audit Logging

Every mutation is logged:

```ruby
AuditLog.log(
  store: store,
  user: current_user,
  action: 'create',
  resource: order,
  changes: { status: [nil, 'pending'] }
)
```

## Development Commands

### Backend (server/)

```bash
cd server

bundle install          # Install dependencies
bundle exec rails s     # Start server
bundle exec sidekiq     # Start background workers
bundle exec rspec       # Run tests
bundle exec rubocop     # Lint code
```

### Frontend (web/)

```bash
cd web

yarn install            # Install dependencies
yarn dev                # Start dev server
yarn build              # Build for production
yarn test               # Run tests
yarn codegen            # Generate GraphQL types
yarn lint               # Lint code
```

## Project Structure

```
cartify/
├── server/                 # Rails API
│   ├── app/
│   │   ├── channels/       # ActionCable channels
│   │   ├── graphql/        # GraphQL schema, types, mutations
│   │   ├── jobs/           # Sidekiq background jobs
│   │   ├── models/         # ActiveRecord models
│   │   ├── policies/       # Authorization policies
│   │   └── services/       # Service objects
│   ├── config/
│   ├── db/
│   ├── spec/               # RSpec tests
│   └── README.md
├── web/                    # React frontend
│   ├── src/
│   │   ├── components/     # UI components
│   │   ├── contexts/       # React contexts
│   │   ├── lib/            # Utilities, Apollo setup
│   │   ├── pages/          # Page components
│   │   └── tests/          # Vitest tests
│   └── README.md
├── docker-compose.yml      # Local dev environment
└── .github/workflows/ci.yml # CI configuration
```

## Tradeoffs & Design Decisions

### Chosen
- **JWT auth over sessions**: Stateless, easy to scale, works well with GraphQL
- **Service objects over fat models**: Better testability, clearer business logic
- **Dataloader over includes**: More flexible, lazy-loaded, handles complex graphs
- **Redis ActionCable adapter**: Required for multi-process/Sidekiq subscription triggers

### Next Steps
- [ ] Add GraphQL persisted queries for production
- [ ] Implement rate limiting per store/user
- [ ] Add webhook delivery system
- [ ] Multi-currency support
- [ ] Implement proper refresh tokens
- [ ] Add GraphQL federation for microservices

## License

MIT
