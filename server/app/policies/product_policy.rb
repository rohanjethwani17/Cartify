class ProductPolicy < ApplicationPolicy
  def show?
    member? && belongs_to_store?
  end
  
  def create?
    can_write?
  end
  
  def update?
    can_write? && belongs_to_store?
  end
  
  def destroy?
    owner? && belongs_to_store?
  end
  
  private
  
  def belongs_to_store?
    record.store_id == store&.id
  end
end
