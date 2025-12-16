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
end
