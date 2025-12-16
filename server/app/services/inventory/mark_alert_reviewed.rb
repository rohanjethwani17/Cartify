module Inventory
  class MarkAlertReviewed < ApplicationService
    def initialize(alert:, current_user:)
      super()
      @alert = alert
      @current_user = current_user
    end
    
    def call
      ActiveRecord::Base.transaction do
        @alert.mark_reviewed!(@current_user)
        
        # Create audit log
        AuditLog.log(
          store: @alert.store,
          user: @current_user,
          action: 'mark_reviewed',
          resource: @alert,
          changes: { reviewed: [false, true] }
        )
        
        success(@alert)
      end
    rescue ActiveRecord::RecordInvalid => e
      failure(e.message)
    end
  end
end
