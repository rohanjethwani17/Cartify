import { useState } from 'react'
import { gql, useQuery } from '@apollo/client'
import { Link } from 'react-router-dom'
import { useAuth } from '@/contexts/AuthContext'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent, CardHeader } from '@/components/ui/card'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { formatCurrency, formatDate } from '@/lib/utils'
import { Search, ChevronRight } from 'lucide-react'

const ORDERS_QUERY = gql`
  query Orders($storeId: ID!, $first: Int, $after: String, $search: String, $status: String) {
    orders(storeId: $storeId, first: $first, after: $after, search: $search, status: $status) {
      edges {
        cursor
        node {
          id
          orderNumber
          email
          status
          fulfillmentStatus
          financialStatus
          totalPrice
          createdAt
          lineItems {
            id
            title
            quantity
          }
        }
      }
      pageInfo {
        hasNextPage
        endCursor
      }
      totalCount
    }
  }
`

const statusColors: Record<string, 'default' | 'secondary' | 'success' | 'warning' | 'destructive'> = {
  pending: 'warning',
  confirmed: 'default',
  fulfilled: 'success',
  cancelled: 'destructive',
}

const fulfillmentColors: Record<string, 'default' | 'secondary' | 'success' | 'warning' | 'destructive'> = {
  unfulfilled: 'secondary',
  partial: 'warning',
  fulfilled: 'success',
}

export function OrdersPage() {
  const { currentStoreId } = useAuth()
  const [search, setSearch] = useState('')
  const [statusFilter, setStatusFilter] = useState('')

  const { data, loading, fetchMore } = useQuery(ORDERS_QUERY, {
    variables: {
      storeId: currentStoreId,
      first: 20,
      search: search || undefined,
      status: statusFilter || undefined,
    },
    skip: !currentStoreId,
  })

  const orders = data?.orders?.edges?.map((e: any) => e.node) || []
  const pageInfo = data?.orders?.pageInfo
  const totalCount = data?.orders?.totalCount || 0

  const loadMore = () => {
    if (pageInfo?.hasNextPage) {
      fetchMore({
        variables: {
          after: pageInfo.endCursor,
        },
      })
    }
  }

  return (
    <div className="space-y-6" data-testid="orders-page">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Orders</h1>
          <p className="text-muted-foreground">
            {totalCount} total orders
          </p>
        </div>
      </div>

      <Card>
        <CardHeader>
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search orders..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="pl-9"
                data-testid="search-input"
              />
            </div>
            <div className="flex gap-2">
              {['', 'pending', 'confirmed', 'fulfilled', 'cancelled'].map((status) => (
                <Button
                  key={status || 'all'}
                  variant={statusFilter === status ? 'default' : 'outline'}
                  size="sm"
                  onClick={() => setStatusFilter(status)}
                  data-testid={`filter-${status || 'all'}`}
                >
                  {status || 'All'}
                </Button>
              ))}
            </div>
          </div>
        </CardHeader>
        <CardContent>
          {loading ? (
            <div className="flex justify-center py-8">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
            </div>
          ) : orders.length === 0 ? (
            <div className="text-center py-8 text-muted-foreground">
              No orders found
            </div>
          ) : (
            <>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Order</TableHead>
                    <TableHead>Customer</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Fulfillment</TableHead>
                    <TableHead>Total</TableHead>
                    <TableHead>Date</TableHead>
                    <TableHead></TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {orders.map((order: any) => (
                    <TableRow key={order.id} data-testid={`order-row-${order.orderNumber}`}>
                      <TableCell>
                        <span className="font-medium">{order.orderNumber}</span>
                        <p className="text-xs text-muted-foreground">
                          {order.lineItems.length} item(s)
                        </p>
                      </TableCell>
                      <TableCell>{order.email}</TableCell>
                      <TableCell>
                        <Badge variant={statusColors[order.status]}>
                          {order.status}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        <Badge variant={fulfillmentColors[order.fulfillmentStatus]}>
                          {order.fulfillmentStatus}
                        </Badge>
                      </TableCell>
                      <TableCell>{formatCurrency(order.totalPrice)}</TableCell>
                      <TableCell>{formatDate(order.createdAt)}</TableCell>
                      <TableCell>
                        <Button asChild variant="ghost" size="icon">
                          <Link to={`/orders/${order.id}`}>
                            <ChevronRight className="h-4 w-4" />
                          </Link>
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>

              {pageInfo?.hasNextPage && (
                <div className="flex justify-center pt-4">
                  <Button variant="outline" onClick={loadMore}>
                    Load More
                  </Button>
                </div>
              )}
            </>
          )}
        </CardContent>
      </Card>
    </div>
  )
}
