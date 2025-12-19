require 'rails_helper'

RSpec.describe 'GraphQL Query Limits' do
  let(:store) { create(:store) }
  let(:user) { create(:user) }
  let!(:membership) { create(:store_membership, :owner, store: store, user: user) }
  let(:context) { { current_user: user, current_store: store } }

  describe 'query depth limit' do
    it 'schema has max_depth configured' do
      # Verify the schema has depth limiting enabled
      expect(CartifySchema.max_depth).to eq(15)
    end

    it 'allows queries within depth limit' do
      valid_query = <<~GQL
        query {
          products(storeId: "#{store.id}", first: 1) {
            edges {
              node {
                id
                title
                variants {
                  id
                  price
                }
              }
            }
          }
        }
      GQL

      result = CartifySchema.execute(valid_query, context: context)

      expect(result['errors']).to be_nil
    end
  end

  describe 'query complexity limit' do
    it 'schema has max_complexity configured' do
      expect(CartifySchema.max_complexity).to eq(300)
    end

    it 'schema has default_max_page_size configured' do
      expect(CartifySchema.default_max_page_size).to eq(50)
    end
  end
end
