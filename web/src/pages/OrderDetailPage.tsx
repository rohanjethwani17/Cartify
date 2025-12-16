import { useParams } from 'react-router-dom'
import { gql, useQuery, useMutation, useSubscription } from '@apollo/client'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { formatCurrency, formatDate } from '@/lib/utils'
import { useToast } from '@/components/ui/use-toast'
import { Package, Truck, CheckCircle, ArrowLeft } from 'lucide-react'
import { Link } from 'react-router-dom'
import { useEffect } from 'react'

const ORDER_QUERY = gql`
  query Order($id: ID!) {
    order(id: $id) {
      id
      orderNumber
      email
      status
      fulfillmentStatus
      financialStatus
      subtotal
      totalTax
      totalShipping
      totalPrice
      currency
      shippingAddress
      note
      createdAt
      updatedAt
      lineItems {
        id
        title
        variantTitle
        sku
        quantity
        price
        fulfilledQuantity
        remainingToFulfill
        variant {
          id
          displayName
        }
      }
      fulfillments {
        id
        status
        trackingNumber
        trackingCompany
        trackingUrl
        shippedAt
      }
    }
  }
`

const UPDATE_FULFILLMENT_MUTATION = gql`
  mutation UpdateFulfillmentStatus(
    $orderId: ID!
    $status: String!
    $trackingNumber: String
    $trackingCompany: String
  ) {
    updateFulfillmentStatus(
      orderId: $orderId
      status: $status
      trackingNumber: $trackingNumber
      trackingCompany: $trackingCompany
    ) {
      order {
        id
        fulfillmentStatus
        status
      }
      errors
    }
  }
`

const FULFILLMENT_SUBSCRIPTION = gql`
  subscription FulfillmentStatusChanged($orderId: ID!) {
    fulfillmentStatusChanged(orderId: $orderId) {
      id
      fulfillmentStatus
      status
      lineItems {
        id
        fulfilledQuantity
        remainingToFulfill
      }
    }
  }
`

const statusColors: Record<string, 'default' | 'secondary' | 'success' | 'warning' | 'destructive'> = {
  pending: 'warning',
  confirmed: 'default',
  fulfilled: 'success',
  cancelled: 'destructive',
}

export function OrderDetailPage() {
  const { id } = useParams<{ id: string }>()
  const { toast } = useToast()

  const { data, loading, refetch } = useQuery(ORDER_QUERY, {
    variables: { id },
    skip: !id,
  })

  const [updateFulfillment, { loading: updating }] = useMutation(UPDATE_FULFILLMENT_MUTATION)

  // Subscribe to fulfillment updates
  const { data: subscriptionData } = useSubscription(FULFILLMENT_SUBSCRIPTION, {
    variables: { orderId: id },
    skip: !id,
  })

  useEffect(() => {
    if (subscriptionData?.fulfillmentStatusChanged) {
      refetch()
      toast({
        title: 'Order Updated',
        description: `Fulfillment status changed to ${subscriptionData.fulfillmentStatusChanged.fulfillmentStatus}`,
      })
    }
  }, [subscriptionData, refetch, toast])

  const handleFulfill = async () => {
    try {
      const result = await updateFulfillment({
        variables: {
          orderId: id,
          status: 'fulfilled',
          trackingNumber: `TRK${Date.now()}`,
          trackingCompany: 'Demo Carrier',
        },
      })

      if (result.data?.updateFulfillmentStatus?.errors?.length > 0) {
        toast({
          title: 'Error',
          description: result.data.updateFulfillmentStatus.errors.join(', '),
          variant: 'destructive',
        })
      } else {
        toast({
          title: 'Success',
          description: 'Order marked as fulfilled',
        })
        refetch()
      }
    } catch (error) {
      toast({
        title: 'Error',
        description: 'Failed to update fulfillment status',
        variant: 'destructive',
      })
    }
  }

  if (loading) {
    return (
      <div className="flex justify-center py-8">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary" />
      </div>
    )
  }

  const order = data?.order

  if (!order) {
    return (
      <div className="text-center py-8">
        <p className="text-muted-foreground">Order not found</p>
        <Button asChild className="mt-4">
          <Link to="/orders">Back to Orders</Link>
        </Button>
      </div>
    )
  }

  const address = order.shippingAddress || {}

  return (
    <div className="space-y-6" data-testid="order-detail">
      <div className="flex items-center gap-4">
        <Button asChild variant="ghost" size="icon">
          <Link to="/orders">
            <ArrowLeft className="h-5 w-5" />
          </Link>
        </Button>
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Order {order.orderNumber}</h1>
          <p className="text-muted-foreground">{formatDate(order.createdAt)}</p>
        </div>
        <div className="ml-auto flex gap-2">
          <Badge variant={statusColors[order.status]}>{order.status}</Badge>
          <Badge variant={order.fulfillmentStatus === 'fulfilled' ? 'success' : 'secondary'}>
            {order.fulfillmentStatus}
          </Badge>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Line Items */}
        <div className="lg:col-span-2">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Package className="h-5 w-5" />
                Line Items
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {order.lineItems.map((item: any) => (
                  <div
                    key={item.id}
                    className="flex items-center justify-between p-4 bg-gray-50 rounded-lg"
                    data-testid={`line-item-${item.id}`}
                  >
                    <div>
                      <p className="font-medium">{item.title}</p>
                      <p className="text-sm text-muted-foreground">
                        {item.variantTitle} • SKU: {item.sku}
                      </p>
                    </div>
                    <div className="text-right">
                      <p className="font-medium">
                        {item.quantity} x {formatCurrency(item.price)}
                      </p>
                      {item.remainingToFulfill > 0 && (
                        <p className="text-sm text-orange-600">
                          {item.remainingToFulfill} to fulfill
                        </p>
                      )}
                      {item.remainingToFulfill === 0 && (
                        <p className="text-sm text-green-600 flex items-center gap-1">
                          <CheckCircle className="h-3 w-3" /> Fulfilled
                        </p>
                      )}
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>

          {/* Fulfillments */}
          {order.fulfillments.length > 0 && (
            <Card className="mt-6">
              <CardHeader>
                <CardTitle className="flex items-center gap-2">
                  <Truck className="h-5 w-5" />
                  Fulfillments
                </CardTitle>
              </CardHeader>
              <CardContent>
                <div className="space-y-4">
                  {order.fulfillments.map((fulfillment: any) => (
                    <div
                      key={fulfillment.id}
                      className="p-4 bg-gray-50 rounded-lg"
                    >
                      <div className="flex items-center justify-between">
                        <Badge variant={fulfillment.status === 'success' ? 'success' : 'secondary'}>
                          {fulfillment.status}
                        </Badge>
                        <span className="text-sm text-muted-foreground">
                          {fulfillment.shippedAt && formatDate(fulfillment.shippedAt)}
                        </span>
                      </div>
                      {fulfillment.trackingNumber && (
                        <p className="mt-2 text-sm">
                          <span className="text-muted-foreground">Tracking:</span>{' '}
                          {fulfillment.trackingNumber}
                          {fulfillment.trackingCompany && ` (${fulfillment.trackingCompany})`}
                        </p>
                      )}
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          )}
        </div>

        {/* Summary Sidebar */}
        <div className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>Summary</CardTitle>
            </CardHeader>
            <CardContent className="space-y-2">
              <div className="flex justify-between">
                <span className="text-muted-foreground">Subtotal</span>
                <span>{formatCurrency(order.subtotal)}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-muted-foreground">Tax</span>
                <span>{formatCurrency(order.totalTax)}</span>
              </div>
              <div className="flex justify-between">
                <span className="text-muted-foreground">Shipping</span>
                <span>{formatCurrency(order.totalShipping)}</span>
              </div>
              <div className="flex justify-between border-t pt-2 font-medium">
                <span>Total</span>
                <span>{formatCurrency(order.totalPrice)}</span>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Customer</CardTitle>
            </CardHeader>
            <CardContent>
              <p className="font-medium">{order.email}</p>
              {address.first_name && (
                <div className="mt-4 text-sm text-muted-foreground">
                  <p className="font-medium text-foreground">Shipping Address</p>
                  <p>{address.first_name} {address.last_name}</p>
                  <p>{address.address1}</p>
                  {address.address2 && <p>{address.address2}</p>}
                  <p>{address.city}, {address.province} {address.zip}</p>
                  <p>{address.country}</p>
                </div>
              )}
            </CardContent>
          </Card>

          {order.fulfillmentStatus !== 'fulfilled' && (
            <Button
              className="w-full"
              onClick={handleFulfill}
              disabled={updating}
              data-testid="fulfill-button"
            >
              {updating ? 'Processing...' : 'Fulfill Order'}
            </Button>
          )}
        </div>
      </div>
    </div>
  )
}
