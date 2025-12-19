class OrderPolicy < ApplicationPolicy
  def show?
    member?
  end

  def create?
    can_write?
  end

  def update?
    can_write?
  end

  def update_fulfillment?
    can_write?
  end

  protected

  # Order belongs_to :store directly
  def derive_store_from_record
    record&.store
  end
end
