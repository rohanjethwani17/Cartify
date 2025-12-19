require 'rails_helper'

RSpec.describe Inventory::AdjustInventory do
  let(:store) { create(:store, low_stock_threshold: 10) }
  let(:user) { create(:user) }
  let!(:membership) { create(:store_membership, store: store, user: user, role: 'owner') }
  let(:location) { create(:location, store: store) }
  let(:product) { create(:product, store: store) }
  let(:variant) { create(:variant, product: product) }
  let!(:inventory) { create(:inventory_level, variant: variant, location: location, available: 50) }

  describe '#call' do
    context 'adding inventory' do
      it 'increases available count' do
        result = described_class.call(
          variant: variant,
          location: location,
          delta: 25,
          current_user: user
        )

        expect(result.success?).to be true
        expect(result.data.available).to eq(75)
      end

      it 'creates audit log' do
        expect do
          described_class.call(
            variant: variant,
            location: location,
            delta: 10,
            reason: 'Restock',
            current_user: user
          )
        end.to change(AuditLog, :count).by(1)
      end
    end

    context 'reducing inventory' do
      it 'decreases available count' do
        result = described_class.call(
          variant: variant,
          location: location,
          delta: -20,
          current_user: user
        )

        expect(result.success?).to be true
        expect(result.data.available).to eq(30)
      end

      it 'fails when reducing below zero' do
        result = described_class.call(
          variant: variant,
          location: location,
          delta: -100,
          current_user: user
        )

        expect(result.failure?).to be true
        expect(result.errors).to include(/Cannot reduce inventory below zero/)
      end
    end

    context 'low stock alert' do
      it 'creates alert when inventory drops below threshold' do
        expect do
          described_class.call(
            variant: variant,
            location: location,
            delta: -45, # 50 - 45 = 5, below threshold of 10
            current_user: user
          )
        end.to change(InventoryAlert, :count).by(1)
      end
    end
  end
end
