class ApplicationPolicy
  attr_reader :user, :record
  
  def initialize(context, record)
    @user = context[:current_user]
    @context_store = context[:current_store]
    @record = record
  end
  
  def index?
    member?
  end
  
  def show?
    member?
  end
  
  def create?
    can_write?
  end
  
  def update?
    can_write?
  end
  
  def destroy?
    owner?
  end
  
  protected
  
  # Derive store from context OR from record (defensive design)
  # This ensures authorization works even if context[:current_store] wasn't set
  def store
    @store ||= @context_store || derive_store_from_record
  end
  
  # Override in subclasses for record-specific store derivation
  def derive_store_from_record
    return nil unless record.respond_to?(:store)
    record.store
  end
  
  def membership
    return nil unless store && user
    @membership ||= user.store_memberships.find_by(store: store)
  end
  
  def member?
    membership.present?
  end
  
  def can_write?
    membership&.can_write?
  end
  
  def owner?
    membership&.can_manage?
  end
  
  def role
    membership&.role
  end
end
