# Seeds for development/demo

puts 'Creating demo store...'
store = Store.find_or_create_by!(slug: 'demo') do |s|
  s.name = 'Demo Store'
  s.low_stock_threshold = 10
end

puts 'Creating demo user...'
user = User.find_or_create_by!(email: 'demo@cartify.dev') do |u|
  u.name = 'Demo User'
  u.password = 'password123'
end

puts 'Setting up store membership...'
StoreMembership.find_or_create_by!(store: store, user: user) do |m|
  m.role = 'owner'
end

puts 'Creating locations...'
locations = [
  { name: 'Main Warehouse', city: 'San Francisco', province: 'CA', country: 'US' },
  { name: 'East Coast Fulfillment', city: 'New York', province: 'NY', country: 'US' }
].map do |attrs|
  Location.find_or_create_by!(store: store, name: attrs[:name]) do |l|
    l.city = attrs[:city]
    l.province = attrs[:province]
    l.country = attrs[:country]
  end
end

puts 'Creating products...'
products_data = [
  { title: 'Classic T-Shirt', description: 'Comfortable cotton t-shirt', product_type: 'Apparel', vendor: 'Cartify Basics', status: 'active' },
  { title: 'Premium Hoodie', description: 'Warm and cozy hoodie', product_type: 'Apparel', vendor: 'Cartify Basics', status: 'active' },
  { title: 'Coffee Mug', description: '12oz ceramic mug', product_type: 'Accessories', vendor: 'Cartify Home', status: 'active' },
  { title: 'Laptop Sleeve', description: 'Protective laptop sleeve', product_type: 'Tech', vendor: 'Cartify Tech', status: 'active' },
  { title: 'Notebook', description: 'Lined notebook 200 pages', product_type: 'Stationery', vendor: 'Cartify Office', status: 'active' }
]

products_data.each do |data|
  product = Product.find_or_create_by!(store: store, title: data[:title]) do |p|
    p.description = data[:description]
    p.product_type = data[:product_type]
    p.vendor = data[:vendor]
    p.status = data[:status]
  end
  
  # Create variants
  variants_for_product = case data[:title]
  when 'Classic T-Shirt'
    [{ title: 'Small', price: 29.99, sku: 'TS-S' }, { title: 'Medium', price: 29.99, sku: 'TS-M' }, { title: 'Large', price: 29.99, sku: 'TS-L' }]
  when 'Premium Hoodie'
    [{ title: 'Small', price: 59.99, sku: 'HD-S' }, { title: 'Medium', price: 59.99, sku: 'HD-M' }, { title: 'Large', price: 59.99, sku: 'HD-L' }]
  else
    [{ title: 'Default', price: rand(10..50).to_f, sku: data[:title].parameterize.upcase[0..5] }]
  end
  
  variants_for_product.each do |variant_data|
    variant = Variant.find_or_create_by!(product: product, sku: variant_data[:sku]) do |v|
      v.title = variant_data[:title]
      v.price = variant_data[:price]
    end
    
    # Create inventory levels
    locations.each do |location|
      InventoryLevel.find_or_create_by!(variant: variant, location: location) do |il|
        il.available = rand(5..100)
      end
    end
  end
end

puts 'Creating sample orders...'
5.times do |i|
  order = Order.find_or_create_by!(store: store, order_number: "DEM-#{(i + 1).to_s.rjust(6, '0')}") do |o|
    o.email = "customer#{i + 1}@example.com"
    o.status = %w[pending confirmed].sample
    o.fulfillment_status = 'unfulfilled'
    o.financial_status = 'paid'
    o.shipping_address = {
      first_name: "Customer",
      last_name: "#{i + 1}",
      address1: "#{rand(100..999)} Main St",
      city: "San Francisco",
      province: "CA",
      zip: "94102",
      country: "US"
    }
  end
  
  # Add line items
  if order.line_items.empty?
    rand(1..3).times do
      variant = Variant.joins(:product).where(products: { store_id: store.id }).sample
      next unless variant
      
      LineItem.create!(
        order: order,
        variant: variant,
        quantity: rand(1..3)
      )
    end
    
    order.calculate_totals
    order.save!
  end
end

puts 'Seed complete!'
puts "Login with: demo@cartify.dev / password123"
