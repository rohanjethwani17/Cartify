import { createContext, useContext, useState, useEffect, ReactNode } from 'react'
import { gql, useMutation, useQuery } from '@apollo/client'
import { apolloClient } from '../lib/apollo'

interface User {
  id: string
  email: string
  name: string
  stores: Array<{
    id: string
    name: string
    slug: string
  }>
}

interface AuthContextType {
  user: User | null
  token: string | null
  currentStoreId: string | null
  loading: boolean
  signIn: (email: string, password: string) => Promise<{ success: boolean; errors: string[] }>
  signOut: () => void
  setCurrentStoreId: (id: string) => void
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

const SIGN_IN_MUTATION = gql`
  mutation SignIn($input: SignInInput!) {
    signIn(input: $input) {
      user {
        id
        email
        name
        stores {
          id
          name
          slug
        }
      }
      token
      errors
    }
  }
`

const ME_QUERY = gql`
  query Me {
    me {
      id
      email
      name
      stores {
        id
        name
        slug
      }
    }
  }
`

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [token, setToken] = useState<string | null>(() => localStorage.getItem('cartify_token'))
  const [currentStoreId, setCurrentStoreId] = useState<string | null>(() =>
    localStorage.getItem('cartify_store_id')
  )

  const { loading, data } = useQuery(ME_QUERY, {
    skip: !token,
    onCompleted: (data) => {
      if (data?.me) {
        setUser(data.me)
        // Set default store if not set
        if (!currentStoreId && data.me.stores.length > 0) {
          const defaultStoreId = data.me.stores[0].id
          setCurrentStoreId(defaultStoreId)
          localStorage.setItem('cartify_store_id', defaultStoreId)
        }
      }
    },
    onError: () => {
      // Token invalid, clear it
      localStorage.removeItem('cartify_token')
      setToken(null)
    },
  })

  const [signInMutation] = useMutation(SIGN_IN_MUTATION)

  const signIn = async (email: string, password: string) => {
    try {
      const { data } = await signInMutation({ variables: { input: { email, password } } })

      if (data?.signIn?.token) {
        const { token, user } = data.signIn
        localStorage.setItem('cartify_token', token)
        setToken(token)
        setUser(user)

        // Set default store
        if (user.stores.length > 0) {
          const defaultStoreId = user.stores[0].id
          setCurrentStoreId(defaultStoreId)
          localStorage.setItem('cartify_store_id', defaultStoreId)
        }

        return { success: true, errors: [] }
      }

      return { success: false, errors: data?.signIn?.errors || ['Sign in failed'] }
    } catch (error) {
      return { success: false, errors: ['An error occurred during sign in'] }
    }
  }

  const signOut = () => {
    localStorage.removeItem('cartify_token')
    localStorage.removeItem('cartify_store_id')
    setToken(null)
    setUser(null)
    setCurrentStoreId(null)
    apolloClient.clearStore()
  }

  const handleSetCurrentStoreId = (id: string) => {
    setCurrentStoreId(id)
    localStorage.setItem('cartify_store_id', id)
  }

  useEffect(() => {
    if (data?.me) {
      setUser(data.me)
    }
  }, [data])

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        currentStoreId,
        loading,
        signIn,
        signOut,
        setCurrentStoreId: handleSetCurrentStoreId,
      }}
    >
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}
