import { useState, useEffect } from 'react'
import { gql, useQuery, useMutation, useSubscription } from '@apollo/client'
import { useAuth } from '@/contexts/AuthContext'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Badge } from '@/components/ui/badge'
import { useToast } from '@/components/ui/use-toast'
import { Settings, Wifi, WifiOff, Zap, RefreshCw } from 'lucide-react'

const STORE_SETTINGS_QUERY = gql`
  query StoreSettings($storeId: ID!) {
    store(id: $storeId) {
      id
      name
      slug
      lowStockThreshold
      settings
    }
  }
`

const UPDATE_SETTINGS_MUTATION = gql`
  mutation UpdateStoreSettings($storeId: ID!, $lowStockThreshold: Int) {
    updateStoreSettings(storeId: $storeId, lowStockThreshold: $lowStockThreshold) {
      store {
        id
        lowStockThreshold
      }
      errors
    }
  }
`

const GENERATE_DEMO_MUTATION = gql`
  mutation GenerateDemoData($storeId: ID!) {
    generateDemoData(storeId: $storeId) {
      success
      jobId
      errors
    }
  }
`

const SYNC_PROGRESS_SUBSCRIPTION = gql`
  subscription SyncProgress($storeId: ID!) {
    syncProgressUpdated(storeId: $storeId) {
      storeId
      jobId
      status
      progress
      total
      message
      completedAt
    }
  }
`

export function SettingsPage() {
  const { currentStoreId } = useAuth()
  const { toast } = useToast()
  const [threshold, setThreshold] = useState('')
  const [wsConnected, setWsConnected] = useState(true)
  const [lastEvent, setLastEvent] = useState<Date | null>(null)
  const [syncProgress, setSyncProgress] = useState<any>(null)

  const { data, loading } = useQuery(STORE_SETTINGS_QUERY, {
    variables: { storeId: currentStoreId },
    skip: !currentStoreId,
    onCompleted: (data) => {
      if (data?.store?.lowStockThreshold) {
        setThreshold(data.store.lowStockThreshold.toString())
      }
    },
  })

  const [updateSettings, { loading: updating }] = useMutation(UPDATE_SETTINGS_MUTATION)
  const [generateDemo, { loading: generating }] = useMutation(GENERATE_DEMO_MUTATION)

  // Subscribe to sync progress
  const { data: progressData, error: wsError } = useSubscription(SYNC_PROGRESS_SUBSCRIPTION, {
    variables: { storeId: currentStoreId },
    skip: !currentStoreId,
    onData: () => {
      setLastEvent(new Date())
      setWsConnected(true)
    },
  })

  useEffect(() => {
    if (wsError) {
      setWsConnected(false)
    }
  }, [wsError])

  useEffect(() => {
    if (progressData?.syncProgressUpdated) {
      setSyncProgress(progressData.syncProgressUpdated)
      if (progressData.syncProgressUpdated.status === 'completed') {
        toast({
          title: 'Demo Data Generated',
          description: 'Your store has been populated with demo data!',
        })
      }
    }
  }, [progressData, toast])

  const handleSaveSettings = async () => {
    try {
      const result = await updateSettings({
        variables: {
          storeId: currentStoreId,
          lowStockThreshold: parseInt(threshold, 10),
        },
      })

      if (result.data?.updateStoreSettings?.errors?.length > 0) {
        toast({
          title: 'Error',
          description: result.data.updateStoreSettings.errors.join(', '),
          variant: 'destructive',
        })
      } else {
        toast({
          title: 'Success',
          description: 'Settings saved successfully',
        })
      }
    } catch (error) {
      toast({
        title: 'Error',
        description: 'Failed to save settings',
        variant: 'destructive',
      })
    }
  }

  const handleGenerateDemo = async () => {
    try {
      setSyncProgress({ status: 'starting', progress: 0, total: 100, message: 'Starting...' })
      
      const result = await generateDemo({
        variables: { storeId: currentStoreId },
      })

      if (result.data?.generateDemoData?.errors?.length > 0) {
        toast({
          title: 'Error',
          description: result.data.generateDemoData.errors.join(', '),
          variant: 'destructive',
        })
        setSyncProgress(null)
      } else {
        toast({
          title: 'Job Started',
          description: 'Demo data generation has started. Watch for progress updates.',
        })
      }
    } catch (error) {
      toast({
        title: 'Error',
        description: 'Failed to start demo data generation',
        variant: 'destructive',
      })
      setSyncProgress(null)
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

  return (
    <div className="space-y-6" data-testid="settings-page">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Settings</h1>
        <p className="text-muted-foreground">Manage your store configuration</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Store Settings */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Settings className="h-5 w-5" />
              Store Settings
            </CardTitle>
            <CardDescription>Configure your store preferences</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <Label className="text-muted-foreground">Store Name</Label>
              <p className="font-medium">{store?.name}</p>
            </div>
            <div>
              <Label className="text-muted-foreground">Store Slug</Label>
              <p className="font-medium">{store?.slug}</p>
            </div>
            <div className="space-y-2">
              <Label htmlFor="threshold">Low Stock Threshold</Label>
              <div className="flex gap-2">
                <Input
                  id="threshold"
                  type="number"
                  min="0"
                  value={threshold}
                  onChange={(e) => setThreshold(e.target.value)}
                  className="max-w-[150px]"
                  data-testid="threshold-input"
                />
                <Button
                  onClick={handleSaveSettings}
                  disabled={updating}
                  data-testid="save-settings-button"
                >
                  {updating ? 'Saving...' : 'Save'}
                </Button>
              </div>
              <p className="text-sm text-muted-foreground">
                Alerts will trigger when inventory drops below this level
              </p>
            </div>
          </CardContent>
        </Card>

        {/* WebSocket Status */}
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              {wsConnected ? (
                <Wifi className="h-5 w-5 text-green-500" />
              ) : (
                <WifiOff className="h-5 w-5 text-red-500" />
              )}
              WebSocket Connection
            </CardTitle>
            <CardDescription>Real-time subscription status</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="flex items-center gap-2">
              <span className="text-muted-foreground">Status:</span>
              <Badge variant={wsConnected ? 'success' : 'destructive'}>
                {wsConnected ? 'Connected' : 'Disconnected'}
              </Badge>
            </div>
            {lastEvent && (
              <div>
                <span className="text-muted-foreground">Last Event:</span>{' '}
                <span className="font-medium">
                  {lastEvent.toLocaleTimeString()}
                </span>
              </div>
            )}
            <p className="text-sm text-muted-foreground">
              WebSocket connection enables real-time updates for orders, inventory alerts, and sync progress.
            </p>
          </CardContent>
        </Card>

        {/* Demo Data */}
        <Card className="lg:col-span-2">
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Zap className="h-5 w-5" />
              Demo Data Generator
            </CardTitle>
            <CardDescription>
              Generate sample products, inventory, and orders for testing
            </CardDescription>
          </CardHeader>
          <CardContent>
            {syncProgress && syncProgress.status !== 'completed' ? (
              <div className="space-y-4">
                <div className="flex items-center gap-2">
                  <RefreshCw className="h-4 w-4 animate-spin" />
                  <span className="font-medium">{syncProgress.message}</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-2">
                  <div
                    className="bg-primary h-2 rounded-full transition-all duration-300"
                    style={{ width: `${(syncProgress.progress / syncProgress.total) * 100}%` }}
                  />
                </div>
                <p className="text-sm text-muted-foreground">
                  {syncProgress.progress} / {syncProgress.total} ({Math.round((syncProgress.progress / syncProgress.total) * 100)}%)
                </p>
              </div>
            ) : (
              <Button
                onClick={handleGenerateDemo}
                disabled={generating}
                data-testid="generate-demo-button"
              >
                {generating ? 'Starting...' : 'Generate Demo Data'}
              </Button>
            )}
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
