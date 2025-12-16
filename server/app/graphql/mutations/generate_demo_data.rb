module Mutations
  class GenerateDemoData < BaseMutation
    argument :store_id, ID, required: true
    
    field :success, Boolean, null: false
    field :job_id, String, null: true
    field :errors, [String], null: false
    
    def resolve(store_id:)
      require_auth!
      
      store = Store.find(store_id)
      context[:current_store] = store
      authorize!(store, :update)
      
      # Enqueue the background job
      job = GenerateDemoDataJob.perform_later(store_id)
      
      {
        success: true,
        job_id: job.job_id,
        errors: []
      }
    end
  end
end
