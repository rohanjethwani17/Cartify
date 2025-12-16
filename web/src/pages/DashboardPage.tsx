import { gql, useQuery, useSubscription } from '@apollo/client'
import { useAuth } from '@/contexts/AuthContext'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { formatCurrency, formatRelativeTime } from '@/lib/utils'
import {
  ShoppingCart,
  AlertTriangle,
  Clock,
  TrendingUp,
  Package,
  Bell,
} from 'lucide-react'
import { useEffect, useState } from 'react'

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

const INVENTORY_LOW_SUBSCRIPTION = gql`
  subscription InventoryLow($storeId: ID!, $threshold: Int) {
    inventoryLow(storeId: $storeId, threshold: $threshold) {
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
`

export function DashboardPage() {
  const { currentStoreId } = useAuth()
  const [newOrders, setNewOrders] = useState<any[]>([])
  const [newAlerts, setNewAlerts] = useState<any[]>([])

  const { data, loading, refetch } = useQuery(DASHBOARD_QUERY, {
    variables: { storeId: currentStoreId },
    skip: !currentStoreId,
    pollInterval: 30000, // Refresh every 30 seconds
  })

  // Subscribe to new orders
  const { data: orderData } = useSubscription(ORDER_CREATED_SUBSCRIPTION, {
    variables: { storeId: currentStoreId },
    skip: !currentStoreId,
  })

  // Subscribe to low inventory alerts
  const { data: alertData } = useSubscription(INVENTORY_LOW_SUBSCRIPTION, {
    variables: { storeId: currentStoreId, threshold: 10 },
    skip: !currentStoreId,
  })

  useEffect(() => {
    if (orderData?.orderCreated) {
      setNewOrders((prev) => [orderData.orderCreated, ...prev].slice(0, 5))
      refetch()
    }
  }, [orderData, refetch])

  useEffect(() => {
    if (alertData?.inventoryLow) {
      setNewAlerts((prev) => [alertData.inventoryLow, ...prev].slice(0, 5))
      refetch()
    }
  }, [alertData, refetch])

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
      </div>
    )
  }

  const store = data?.store
  const orders = data?.orders?.edges?.map((e: any) => e.node) || []
  const agingSummary = store?.orderAgingSummary || {}
  const alerts = store?.inventoryAlerts || []

  return (
    <div className="space-y-6" data-testid="dashboard">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-muted-foreground">
          Welcome back! Here's what's happening in your store.
        </p>
      </div>

      {/* Order Aging Summary */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
        <Card data-testid="aging-0-1">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Today</CardTitle>
            <TrendingUp className="h-4 w-4 text-green-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{agingSummary.zeroToOneDay || 0}</div>
            <p className="text-xs text-muted-foreground">0-1 day old orders</p>
          </CardContent>
        </Card>
        <Card data-testid="aging-2-3">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">2-3 Days</CardTitle>
            <Clock className="h-4 w-4 text-yellow-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{agingSummary.twoToThreeDays || 0}</div>
            <p className="text-xs text-muted-foreground">Needs attention</p>
          </CardContent>
        </Card>
        <Card data-testid="aging-4-7">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">4-7 Days</CardTitle>
            <AlertTriangle className="h-4 w-4 text-orange-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{agingSummary.fourToSevenDays || 0}</div>
            <p className="text-xs text-muted-foreground">Urgent</p>
          </CardContent>
        </Card>
        <Card data-testid="aging-8-plus">
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">8+ Days</CardTitle>
            <AlertTriangle className="h-4 w-4 text-red-500" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{agingSummary.eightPlusDays || 0}</div>
            <p className="text-xs text-muted-foreground">Critical</p>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Live Orders Feed */}
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <div>
                <CardTitle className="flex items-center gap-2">
                  <ShoppingCart className="h-5 w-5" />
                  New Orders
                </CardTitle>
                <CardDescription>Real-time order feed</CardDescription>
              </div>
              {newOrders.length > 0 && (
                <Badge variant="success" className="animate-pulse">
                  <Bell className="h-3 w-3 mr-1" />
                  {newOrders.length} new
                </Badge>
              )}
            </div>
          </CardHeader>
          <CardContent>
            <div className="space-y-3" data-testid="orders-feed">
              {orders.length === 0 ? (
                <p className="text-center text-muted-foreground py-4">No orders yet</p>
              ) : (
                orders.slice(0, 5).map((order: any) => (
                  <div
                    key={order.id}
                    className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
                    data-testid={`order-${order.orderNumber}`}
                  >
                    <div>
                      <p className="font-medium">{order.orderNumber}</p>
                      <p className="text-sm text-muted-foreground">{order.email}</p>
                    </div>
                    <div className="text-right">
                      <p className="font-medium">{formatCurrency(order.totalPrice)}</p>
                      <p className="text-xs text-muted-foreground">
                        {formatRelativeTime(order.createdAt)}
                      </p>
                    </div>
                  </div>
                ))
              )}
            </div>
          </CardContent>
        </Card>

        {/* Low Stock Alerts */}
        <Card>
          <CardHeader>
            <div className="flex items-center justify-between">
              <div>
                <CardTitle className="flex items-center gap-2">
                  <Package className="h-5 w-5" />
                  Low Stock Alerts
                </CardTitle>
                <CardDescription>Items needing restock</CardDescription>
              </div>
              {alerts.length > 0 && (
                <Badge variant="warning">
                  {alerts.length} alerts
                </Badge>
              )}
            </div>
          </CardHeader>
          <CardContent>
            <div className="space-y-3" data-testid="alerts-feed">
              {alerts.length === 0 ? (
                <p className="text-center text-muted-foreground py-4">No low stock alerts</p>
              ) : (
                alerts.slice(0, 5).map((alert: any) => (
                  <div
                    key={alert.id}
                    className="flex items-center justify-between p-3 bg-yellow-50 rounded-lg"
                    data-testid={`alert-${alert.id}`}
                  >
                    <div>
                      <p className="font-medium">{alert.variant.displayName}</p>
                      <p className="text-sm text-muted-foreground">
                        {alert.location.name} • SKU: {alert.variant.sku}
                      </p>
                    </div>
                    <div className="text-right">
                      <Badge variant="warning">
                        {alert.currentLevel} left
                      </Badge>
                      <p className="text-xs text-muted-foreground mt-1">
                        Threshold: {alert.threshold}
                      </p>
                    </div>
                  </div>
                ))
              )}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
