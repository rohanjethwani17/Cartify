class StorePolicy < ApplicationPolicy
  def show?
    member?
  end
  
  def update?
    owner?
  end
  
  def update_settings?
    owner?
  end
  
  protected
  
  # The record IS the store
  def derive_store_from_record
    record
  end
end
