import { gql, useQuery, useMutation } from '@apollo/client'
import { useAuth } from '@/contexts/AuthContext'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { useToast } from '@/components/ui/use-toast'
import { AlertTriangle, CheckCircle, Search } from 'lucide-react'
import { useState } from 'react'

const INVENTORY_QUERY = gql`
  query Inventory($storeId: ID!, $threshold: Int) {
    store(id: $storeId) {
      id
      lowStockThreshold
      locations {
        id
        name
      }
      inventoryAlerts(reviewed: false) {
        id
        threshold
        currentLevel
        reviewed
        createdAt
        variant {
          id
          title
          sku
          displayName
          product {
            id
            title
          }
        }
        location {
          id
          name
        }
      }
    }
    lowStockVariants(storeId: $storeId, threshold: $threshold) {
      id
      title
      sku
      displayName
      totalAvailable
      product {
        id
        title
      }
      inventoryLevels {
        id
        available
        committed
        location {
          id
          name
        }
      }
    }
  }
`

const MARK_REVIEWED_MUTATION = gql`
  mutation MarkAlertReviewed($alertId: ID!) {
    markInventoryAlertReviewed(alertId: $alertId) {
      inventoryAlert {
        id
        reviewed
        reviewedAt
      }
      errors
    }
  }
`

export function InventoryPage() {
  const { currentStoreId } = useAuth()
  const { toast } = useToast()
  const [search, setSearch] = useState('')
  const [selectedLocation, setSelectedLocation] = useState('')

  const { data, loading, refetch } = useQuery(INVENTORY_QUERY, {
    variables: { storeId: currentStoreId },
    skip: !currentStoreId,
  })

  const [markReviewed, { loading: reviewing }] = useMutation(MARK_REVIEWED_MUTATION)

  const handleMarkReviewed = async (alertId: string) => {
    try {
      const result = await markReviewed({ variables: { alertId } })

      if (result.data?.markInventoryAlertReviewed?.errors?.length > 0) {
        toast({
          title: 'Error',
          description: result.data.markInventoryAlertReviewed.errors.join(', '),
          variant: 'destructive',
        })
      } else {
        toast({
          title: 'Success',
          description: 'Alert marked as reviewed',
        })
        refetch()
      }
    } catch (error) {
      toast({
        title: 'Error',
        description: 'Failed to mark alert as reviewed',
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

  const store = data?.store
  const alerts = store?.inventoryAlerts || []
  const lowStockVariants = data?.lowStockVariants || []
  const locations = store?.locations || []

  // Filter by search and location
  let filteredVariants = lowStockVariants
  if (search) {
    filteredVariants = filteredVariants.filter(
      (v: any) =>
        v.displayName.toLowerCase().includes(search.toLowerCase()) ||
        v.sku?.toLowerCase().includes(search.toLowerCase())
    )
  }

  return (
    <div className="space-y-6" data-testid="inventory-page">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Inventory</h1>
        <p className="text-muted-foreground">
          Monitor stock levels and manage low-stock alerts
        </p>
      </div>

      {/* Alerts Section */}
      {alerts.length > 0 && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <AlertTriangle className="h-5 w-5 text-yellow-500" />
              Low Stock Alerts ({alerts.length})
            </CardTitle>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Product</TableHead>
                  <TableHead>Location</TableHead>
                  <TableHead>Current Level</TableHead>
                  <TableHead>Threshold</TableHead>
                  <TableHead></TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {alerts.map((alert: any) => (
                  <TableRow key={alert.id} data-testid={`alert-row-${alert.id}`}>
                    <TableCell>
                      <p className="font-medium">{alert.variant.displayName}</p>
                      <p className="text-sm text-muted-foreground">SKU: {alert.variant.sku}</p>
                    </TableCell>
                    <TableCell>{alert.location.name}</TableCell>
                    <TableCell>
                      <Badge variant="warning">{alert.currentLevel}</Badge>
                    </TableCell>
                    <TableCell>{alert.threshold}</TableCell>
                    <TableCell>
                      <Button
                        size="sm"
                        variant="outline"
                        onClick={() => handleMarkReviewed(alert.id)}
                        disabled={reviewing}
                        data-testid={`mark-reviewed-${alert.id}`}
                      >
                        <CheckCircle className="h-4 w-4 mr-1" />
                        Mark Reviewed
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      )}

      {/* Low Stock Table */}
      <Card>
        <CardHeader>
          <div className="flex flex-col sm:flex-row gap-4">
            <div className="relative flex-1">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Search products..."
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                className="pl-9"
                data-testid="search-input"
              />
            </div>
            <div className="flex gap-2">
              <Button
                variant={selectedLocation === '' ? 'default' : 'outline'}
                size="sm"
                onClick={() => setSelectedLocation('')}
              >
                All Locations
              </Button>
              {locations.map((loc: any) => (
                <Button
                  key={loc.id}
                  variant={selectedLocation === loc.id ? 'default' : 'outline'}
                  size="sm"
                  onClick={() => setSelectedLocation(loc.id)}
                >
                  {loc.name}
                </Button>
              ))}
            </div>
          </div>
        </CardHeader>
        <CardContent>
          {filteredVariants.length === 0 ? (
            <div className="text-center py-8 text-muted-foreground">
              No low stock items found
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Product</TableHead>
                  <TableHead>SKU</TableHead>
                  <TableHead>Total Available</TableHead>
                  <TableHead>By Location</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredVariants.map((variant: any) => {
                  const levels = selectedLocation
                    ? variant.inventoryLevels.filter((l: any) => l.location.id === selectedLocation)
                    : variant.inventoryLevels

                  return (
                    <TableRow key={variant.id} data-testid={`variant-row-${variant.id}`}>
                      <TableCell>
                        <p className="font-medium">{variant.product.title}</p>
                        <p className="text-sm text-muted-foreground">{variant.title}</p>
                      </TableCell>
                      <TableCell>{variant.sku || '-'}</TableCell>
                      <TableCell>
                        <Badge
                          variant={
                            variant.totalAvailable === 0
                              ? 'destructive'
                              : variant.totalAvailable <= 10
                              ? 'warning'
                              : 'default'
                          }
                        >
                          {variant.totalAvailable}
                        </Badge>
                      </TableCell>
                      <TableCell>
                        <div className="space-y-1">
                          {levels.map((level: any) => (
                            <div key={level.id} className="text-sm">
                              <span className="text-muted-foreground">{level.location.name}:</span>{' '}
                              <span className="font-medium">{level.available}</span>
                              {level.committed > 0 && (
                                <span className="text-orange-600"> ({level.committed} committed)</span>
                              )}
                            </div>
                          ))}
                        </div>
                      </TableCell>
                    </TableRow>
                  )
                })}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>
    </div>
  )
}
