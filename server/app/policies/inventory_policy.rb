class InventoryPolicy < ApplicationPolicy
  def adjust?
    can_write?
  end
  
  def mark_reviewed?
    can_write?
  end
end
