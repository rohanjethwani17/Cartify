class ProductPolicy < ApplicationPolicy
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

  # Product belongs_to :store directly
  def derive_store_from_record
    record&.store
  end
end
