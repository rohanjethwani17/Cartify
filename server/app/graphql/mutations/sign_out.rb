module Mutations
  class SignOut < BaseMutation
    field :success, Boolean, null: false
    
    def resolve
      # In a JWT-based system, sign out is typically handled client-side
      # by removing the token. This mutation exists for API completeness.
      { success: true }
    end
  end
end
