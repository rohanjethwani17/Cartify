require 'rails_helper'

RSpec.describe 'OrderCreated Subscription' do
  let(:store) { create(:store) }
  let(:user) { create(:user) }
  let!(:membership) { create(:store_membership, :owner, store: store, user: user) }
  let(:location) { create(:location, store: store) }
  let(:product) { create(:product, store: store) }
  let(:variant) { create(:variant, product: product) }
  let!(:inventory) { create(:inventory_level, variant: variant, location: location, available: 100) }

  it 'triggers subscription when order is created' do
    # Create a mock subscription
    triggered_data = nil

    allow(CartifySchema.subscriptions).to receive(:trigger) do |event, args, data|
      triggered_data = { event: event, args: args, data: data } if event == :order_created
    end

    # Create an order
    Orders::CreateOrder.call(
      store: store,
      line_items: [{ variant_id: variant.id, quantity: 1 }],
      email: 'test@example.com',
      current_user: user
    )

    expect(triggered_data).not_to be_nil
    expect(triggered_data[:event]).to eq(:order_created)
    expect(triggered_data[:args][:store_id]).to eq(store.id)
    expect(triggered_data[:data]).to be_a(Order)
  end
end
