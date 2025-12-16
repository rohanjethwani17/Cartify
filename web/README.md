# Cartify Web

React TypeScript frontend for Cartify - a multi-tenant commerce operations platform.

## Architecture

```
web/
├── src/
│   ├── components/
│   │   ├── ui/              # Reusable UI components (shadcn/ui style)
│   │   └── Layout.tsx        # Main app layout
│   ├── contexts/
│   │   └── AuthContext.tsx   # Authentication state
│   ├── lib/
│   │   ├── apollo.ts         # Apollo Client configuration
│   │   └── utils.ts          # Utility functions
│   ├── pages/
│   │   ├── DashboardPage.tsx # Real-time dashboard
│   │   ├── OrdersPage.tsx    # Order list with pagination
│   │   ├── OrderDetailPage.tsx # Order detail with fulfillment
│   │   ├── InventoryPage.tsx # Low stock management
│   │   └── SettingsPage.tsx  # Store settings + WS status
│   └── tests/              # Vitest tests
├── codegen.ts              # GraphQL Code Generator config
└── package.json
```

## GraphQL Client Setup

### Apollo Client with Subscriptions

We use Apollo Client with a split link:
- **HTTP Link**: For queries and mutations
- **WebSocket Link (graphql-ws)**: For subscriptions

```typescript
// src/lib/apollo.ts
const splitLink = split(
  ({ query }) => {
    const definition = getMainDefinition(query)
    return (
      definition.kind === 'OperationDefinition' &&
      definition.operation === 'subscription'
    )
  },
  wsLink,
  authLink.concat(httpLink)
)
```

### Subscription Usage

```typescript
const { data } = useSubscription(ORDER_CREATED_SUBSCRIPTION, {
  variables: { storeId: currentStoreId },
})

useEffect(() => {
  if (data?.orderCreated) {
    // Handle new order - update UI, show notification, etc.
    refetch()
  }
}, [data])
```

## Commands

```bash
# Install dependencies
yarn install

# Start development server
yarn dev

# Build for production
yarn build

# Run tests
yarn test

# Generate GraphQL types (requires server running)
yarn codegen

# Lint code
yarn lint
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|--------|
| VITE_GRAPHQL_HTTP_URL | GraphQL HTTP endpoint | http://localhost:3000/graphql |
| VITE_GRAPHQL_WS_URL | GraphQL WebSocket endpoint | ws://localhost:3000/cable |

## Key Features

### 1. Dashboard
- Real-time order feed via subscriptions
- Live low-stock alerts
- Order aging summary (0-1d, 2-3d, 4-7d, 8+d)

### 2. Orders
- Cursor-based pagination
- Search and filter by status
- Real-time fulfillment status updates

### 3. Inventory
- Low-stock variant table
- Filter by location
- One-click "mark reviewed" action

### 4. Settings
- Configure low-stock threshold
- WebSocket connection status indicator
- Demo data generator with progress subscription

## Type Safety

We use GraphQL Code Generator to create typed hooks:

```bash
# Generate types (server must be running)
yarn codegen
```

This creates `src/generated/graphql.tsx` with:
- TypeScript types for all GraphQL operations
- Typed React hooks (`useQueryQuery`, `useMutationMutation`, etc.)

## Testing

```bash
# Run all tests
yarn test

# Run with UI
yarn test:ui
```

Tests use:
- **Vitest**: Test runner
- **@testing-library/react**: Component testing
- **MockedProvider**: Apollo Client mocking

## Tradeoffs & Next Steps

### Current Tradeoffs
- No optimistic updates for mutations (keeping it simple)
- Polling fallback every 30s (in case WS disconnects)
- Manual refetch after subscription events (vs cache updates)

### Next Steps
- Implement optimistic UI updates
- Add proper error boundaries
- Cache normalization for subscription data
- PWA support for mobile admin
- Dark mode support
