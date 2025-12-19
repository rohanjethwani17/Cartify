require 'rails_helper'

RSpec.describe Orders::CreateOrder do
  let(:store) { create(:store) }
  let(:user) { create(:user) }
  let!(:membership) { create(:store_membership, store: store, user: user, role: 'owner') }
  let(:location) { create(:location, store: store) }
  let(:product) { create(:product, store: store) }
  let(:variant) { create(:variant, product: product) }
  let!(:inventory) { create(:inventory_level, variant: variant, location: location, available: 100) }

  describe '#call' do
    context 'with valid params' do
      let(:params) do
        {
          store: store,
          line_items: [{ variant_id: variant.id, quantity: 2 }],
          email: 'test@example.com',
          current_user: user
        }
      end

      it 'creates an order' do
        result = described_class.call(**params)

        expect(result.success?).to be true
        expect(result.data).to be_a(Order)
        expect(result.data.email).to eq('test@example.com')
      end

      it 'creates line items' do
        result = described_class.call(**params)

        expect(result.data.line_items.count).to eq(1)
        expect(result.data.line_items.first.quantity).to eq(2)
      end

      it 'reserves inventory' do
        described_class.call(**params)
        inventory.reload

        expect(inventory.available).to eq(98)
        expect(inventory.committed).to eq(2)
      end

      it 'creates an audit log' do
        expect do
          described_class.call(**params)
        end.to change(AuditLog, :count).by(1)
      end
    end

    context 'with idempotency key' do
      let(:params) do
        {
          store: store,
          line_items: [{ variant_id: variant.id, quantity: 1 }],
          idempotency_key: 'unique-key-123',
          current_user: user
        }
      end

      it 'returns existing order on duplicate request' do
        first_result = described_class.call(**params)
        second_result = described_class.call(**params)

        expect(first_result.data.id).to eq(second_result.data.id)
      end

      it 'does not create duplicate orders' do
        described_class.call(**params)

        expect do
          described_class.call(**params)
        end.not_to change(Order, :count)
      end
    end

    context 'with insufficient inventory' do
      let(:params) do
        {
          store: store,
          line_items: [{ variant_id: variant.id, quantity: 200 }],
          current_user: user
        }
      end

      it 'returns failure' do
        result = described_class.call(**params)

        expect(result.failure?).to be true
        expect(result.errors).to include(/Insufficient inventory/)
      end
    end
  end
end
