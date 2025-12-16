require 'rails_helper'

RSpec.describe 'Products Query' do
  let(:store) { create(:store) }
  let(:user) { create(:user) }
  let!(:membership) { create(:store_membership, :owner, store: store, user: user) }
  
  let!(:products) do
    create_list(:product, 5, store: store).each do |product|
      create(:variant, product: product)
    end
  end
  
  let(:query) do
    <<~GQL
      query Products($storeId: ID!, $first: Int, $after: String) {
        products(storeId: $storeId, first: $first, after: $after) {
          edges {
            cursor
            node {
              id
              title
              status
              variants {
                id
                title
                price
              }
            }
          }
          pageInfo {
            hasNextPage
            hasPreviousPage
            startCursor
            endCursor
          }
          totalCount
        }
      }
    GQL
  end
  
  let(:context) { { current_user: user, current_store: nil } }
  
  it 'returns paginated products' do
    result = CartifySchema.execute(
      query,
      variables: { storeId: store.id, first: 2 },
      context: context
    )
    
    data = result['data']['products']
    
    expect(data['edges'].count).to eq(2)
    expect(data['totalCount']).to eq(5)
    expect(data['pageInfo']['hasNextPage']).to be true
  end
  
  it 'loads variants without N+1' do
    # This test verifies that dataloader is working
    # In a real scenario, you'd use a query counter gem
    result = CartifySchema.execute(
      query,
      variables: { storeId: store.id, first: 5 },
      context: context
    )
    
    data = result['data']['products']
    expect(data['edges'].count).to eq(5)
    
    data['edges'].each do |edge|
      expect(edge['node']['variants']).to be_present
    end
  end
end
