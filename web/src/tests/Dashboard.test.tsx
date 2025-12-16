import { describe, it, expect, vi, beforeEach } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import { MockedProvider } from '@apollo/client/testing'
import { BrowserRouter } from 'react-router-dom'
import { DashboardPage } from '../pages/DashboardPage'
import { AuthProvider } from '../contexts/AuthContext'
import { gql } from '@apollo/client'

// Mock the auth context
vi.mock('../contexts/AuthContext', () => ({
  useAuth: () => ({
    currentStoreId: 'store-1',
    user: { id: '1', email: 'test@example.com', name: 'Test User', stores: [] },
  }),
  AuthProvider: ({ children }: { children: React.ReactNode }) => children,
}))

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

const mockDashboardData = {
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
          zeroToOneDay: 5,
          twoToThreeDays: 3,
          fourToSevenDays: 2,
          eightPlusDays: 1,
        },
        inventoryAlerts: [
          {
            id: 'alert-1',
            threshold: 10,
            currentLevel: 5,
            createdAt: new Date().toISOString(),
            variant: {
              id: 'variant-1',
              displayName: 'Test Product - Small',
              sku: 'TEST-S',
            },
            location: {
              id: 'loc-1',
              name: 'Main Warehouse',
            },
          },
        ],
      },
      orders: {
        edges: [
          {
            node: {
              id: 'order-1',
              orderNumber: 'ORD-000001',
              email: 'customer@example.com',
              totalPrice: 99.99,
              status: 'pending',
              fulfillmentStatus: 'unfulfilled',
              createdAt: new Date().toISOString(),
            },
          },
        ],
      },
    },
  },
}

describe('DashboardPage', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  it('renders dashboard with order aging summary', async () => {
    render(
      <MockedProvider mocks={[mockDashboardData]} addTypename={false}>
        <BrowserRouter>
          <DashboardPage />
        </BrowserRouter>
      </MockedProvider>
    )

    await waitFor(() => {
      expect(screen.getByTestId('dashboard')).toBeInTheDocument()
    })

    // Check aging summary cards
    await waitFor(() => {
      expect(screen.getByTestId('aging-0-1')).toBeInTheDocument()
    })
  })

  it('renders orders feed', async () => {
    render(
      <MockedProvider mocks={[mockDashboardData]} addTypename={false}>
        <BrowserRouter>
          <DashboardPage />
        </BrowserRouter>
      </MockedProvider>
    )

    await waitFor(() => {
      expect(screen.getByTestId('orders-feed')).toBeInTheDocument()
    })
  })

  it('renders inventory alerts', async () => {
    render(
      <MockedProvider mocks={[mockDashboardData]} addTypename={false}>
        <BrowserRouter>
          <DashboardPage />
        </BrowserRouter>
      </MockedProvider>
    )

    await waitFor(() => {
      expect(screen.getByTestId('alerts-feed')).toBeInTheDocument()
    })
  })
})
