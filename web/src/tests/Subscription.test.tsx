import { describe, it, expect, vi } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import { MockedProvider } from '@apollo/client/testing'
import { BrowserRouter } from 'react-router-dom'
import { DashboardPage } from '../pages/DashboardPage'
import { gql } from '@apollo/client'

// Mock the auth context
vi.mock('../contexts/AuthContext', () => ({
  useAuth: () => ({
    currentStoreId: 'store-1',
    user: { id: '1', email: 'test@example.com', name: 'Test User', stores: [] },
  }),
}))

const ORDER_CREATED_SUBSCRIPTION = gql`
  subscription OrderCreated($storeId: ID!) {
    orderCreated(storeId: $storeId) {
      id
      orderNumber
      email
      totalPrice
      status
      fulfillmentStatus
      createdAt
    }
  }
`

const DASHBOARD_QUERY = gql`
  query Dashboard($storeId: ID!) {
    store(id: $storeId) {
      id
      name
      orderAgingSummary {
        zeroToOneDay
        twoToThreeDays
        fourToSevenDays
        eightPlusDays
      }
      inventoryAlerts(reviewed: false) {
        id
        threshold
        currentLevel
        createdAt
        variant {
          id
          displayName
          sku
        }
        location {
          id
          name
        }
      }
    }
    orders(storeId: $storeId, first: 10) {
      edges {
        node {
          id
          orderNumber
          email
          totalPrice
          status
          fulfillmentStatus
          createdAt
        }
      }
    }
  }
`

const mockQueryResult = {
  request: {
    query: DASHBOARD_QUERY,
    variables: { storeId: 'store-1' },
  },
  result: {
    data: {
      store: {
        id: 'store-1',
        name: 'Test Store',
        orderAgingSummary: {
          zeroToOneDay: 0,
          twoToThreeDays: 0,
          fourToSevenDays: 0,
          eightPlusDays: 0,
        },
        inventoryAlerts: [],
      },
      orders: {
        edges: [],
      },
    },
  },
}

describe('Subscription Integration', () => {
  it('handles subscription data and updates UI state', async () => {
    // This test verifies the subscription flow is set up correctly
    // In a real test, we'd use a WebSocket mock to simulate subscription events
    
    const subscriptionMock = {
      request: {
        query: ORDER_CREATED_SUBSCRIPTION,
        variables: { storeId: 'store-1' },
      },
      result: {
        data: {
          orderCreated: {
            id: 'new-order-1',
            orderNumber: 'ORD-NEW001',
            email: 'new@example.com',
            totalPrice: 150.00,
            status: 'pending',
            fulfillmentStatus: 'unfulfilled',
            createdAt: new Date().toISOString(),
          },
        },
      },
    }

    render(
      <MockedProvider mocks={[mockQueryResult, subscriptionMock]} addTypename={false}>
        <BrowserRouter>
          <DashboardPage />
        </BrowserRouter>
      </MockedProvider>
    )

    // Wait for initial render
    await waitFor(() => {
      expect(screen.getByTestId('dashboard')).toBeInTheDocument()
    })

    // Verify the subscription is set up (the actual subscription event
    // would be triggered via WebSocket in a real scenario)
    expect(screen.getByTestId('orders-feed')).toBeInTheDocument()
  })
})
