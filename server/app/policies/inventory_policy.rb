class InventoryPolicy < ApplicationPolicy
  def adjust?
    can_write?
  end
  
  def mark_reviewed?
    can_write?
  end
  
  protected
  
  # InventoryLevel -> Location -> Store
  # InventoryAlert -> Store
  def derive_store_from_record
    case record
    when InventoryLevel
      record.location&.store
    when InventoryAlert
      record.store
    when Location
      record.store
    else
      record.respond_to?(:store) ? record.store : nil
    end
  end
end
