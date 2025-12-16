import {
  ApolloClient,
  InMemoryCache,
  createHttpLink,
  split,
} from '@apollo/client'
import { setContext } from '@apollo/client/link/context'
import { GraphQLWsLink } from '@apollo/client/link/subscriptions'
import { getMainDefinition } from '@apollo/client/utilities'
import { createClient } from 'graphql-ws'

const GRAPHQL_HTTP_URL = import.meta.env.VITE_GRAPHQL_HTTP_URL || 'http://localhost:3000/graphql'
const GRAPHQL_WS_URL = import.meta.env.VITE_GRAPHQL_WS_URL || 'ws://localhost:3000/cable'

// HTTP link for queries and mutations
const httpLink = createHttpLink({
  uri: GRAPHQL_HTTP_URL,
})

// Auth link to add JWT token
const authLink = setContext((_, { headers }) => {
  const token = localStorage.getItem('cartify_token')
  return {
    headers: {
      ...headers,
      authorization: token ? `Bearer ${token}` : '',
    },
  }
})

// WebSocket link for subscriptions using graphql-ws
const wsLink = new GraphQLWsLink(
  createClient({
    url: GRAPHQL_WS_URL,
    connectionParams: () => {
      const token = localStorage.getItem('cartify_token')
      return {
        token,
      }
    },
    // Reconnection settings
    retryAttempts: 5,
    shouldRetry: () => true,
  })
)

// Split link: use WebSocket for subscriptions, HTTP for queries/mutations
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

export const apolloClient = new ApolloClient({
  link: splitLink,
  cache: new InMemoryCache({
    typePolicies: {
      Query: {
        fields: {
          products: {
            keyArgs: ['storeId', 'search', 'status'],
            merge(existing, incoming, { args }) {
              if (!args?.after) return incoming
              return {
                ...incoming,
                edges: [...(existing?.edges || []), ...incoming.edges],
              }
            },
          },
          orders: {
            keyArgs: ['storeId', 'search', 'status'],
            merge(existing, incoming, { args }) {
              if (!args?.after) return incoming
              return {
                ...incoming,
                edges: [...(existing?.edges || []), ...incoming.edges],
              }
            },
          },
        },
      },
    },
  }),
  defaultOptions: {
    watchQuery: {
      errorPolicy: 'all',
    },
    query: {
      errorPolicy: 'all',
    },
    mutate: {
      errorPolicy: 'all',
    },
  },
})
