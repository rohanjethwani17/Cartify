class ApplicationPolicy
  attr_reader :user, :store, :record
  
  def initialize(context, record)
    @user = context[:current_user]
    @store = context[:current_store]
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
  
  def membership
    @membership ||= user&.store_memberships&.find_by(store: store)
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
