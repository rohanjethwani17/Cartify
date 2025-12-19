class GenerateDemoDataJob < ApplicationJob
  queue_as :default

  # Make job idempotent with unique job ID
  def perform(store_id)
    @store = Store.find(store_id)
    @job_id = job_id
    @total_steps = 100
    @current_step = 0

    broadcast_progress('Starting demo data generation...')

    # Generate products (40%)
    generate_products

    # Generate inventory (30%)
    generate_inventory

    # Generate orders (30%)
    generate_orders

    broadcast_progress('Demo data generation complete!', completed: true)
  end

  private

  def generate_products
    product_data = [
      { title: 'Wireless Headphones', type: 'Electronics', vendor: 'TechGear', variants: %w[Black White Blue] },
      { title: 'Organic Coffee Beans', type: 'Food & Beverage', vendor: 'RoastMaster',
        variants: ['Light Roast', 'Medium Roast', 'Dark Roast'] },
      { title: 'Yoga Mat', type: 'Fitness', vendor: 'ZenFit', variants: ['Standard', 'Extra Thick'] },
      { title: 'Leather Wallet', type: 'Accessories', vendor: 'CraftLeather', variants: %w[Brown Black Tan] },
      { title: 'Smart Watch', type: 'Electronics', vendor: 'TechGear', variants: %w[40mm 44mm] },
      { title: 'Running Shoes', type: 'Footwear', vendor: 'SpeedRun',
        variants: ['Size 8', 'Size 9', 'Size 10', 'Size 11'] },
      { title: 'Desk Lamp', type: 'Home Office', vendor: 'LightWorks', variants: %w[White Black] },
      { title: 'Reusable Water Bottle', type: 'Accessories', vendor: 'EcoLife', variants: %w[500ml 750ml 1L] },
      { title: 'Bluetooth Speaker', type: 'Electronics', vendor: 'SoundWave', variants: %w[Mini Standard XL] },
      { title: 'Cotton T-Shirt', type: 'Apparel', vendor: 'BasicWear', variants: %w[S M L XL] }
    ]

    products_created = 0
    product_data.each do |data|
      next if @store.products.exists?(title: data[:title])

      product = @store.products.create!(
        title: data[:title],
        description: "High quality #{data[:title].downcase} for everyday use.",
        product_type: data[:type],
        vendor: data[:vendor],
        status: 'active'
      )

      # Remove default variant
      product.variants.destroy_all

      data[:variants].each_with_index do |variant_title, index|
        product.variants.create!(
          title: variant_title,
          sku: "#{data[:title].parameterize.upcase[0..3]}-#{variant_title.parameterize.upcase[0..2]}",
          price: rand(15..150).round(2),
          position: index
        )
      end

      products_created += 1
      update_progress(products_created * 4, "Created product: #{data[:title]}")
    end
  end

  def generate_inventory
    locations = @store.locations.active.to_a

    if locations.empty?
      locations = [
        @store.locations.create!(name: 'Main Warehouse', city: 'San Francisco', province: 'CA', country: 'US'),
        @store.locations.create!(name: 'East Coast DC', city: 'New York', province: 'NY', country: 'US')
      ]
    end

    variants = Variant.joins(:product).where(products: { store_id: @store.id })
    variants_count = variants.count

    variants.each_with_index do |variant, index|
      locations.each do |location|
        inventory_level = InventoryLevel.find_or_initialize_by(variant: variant, location: location)
        inventory_level.available = rand(0..100)
        inventory_level.save!

        # Create low stock alerts for items below threshold
        next unless inventory_level.available <= @store.low_stock_threshold

        InventoryAlert.find_or_create_by!(
          store: @store,
          variant: variant,
          location: location
        ) do |alert|
          alert.threshold = @store.low_stock_threshold
          alert.current_level = inventory_level.available
        end
      end

      progress = 40 + ((index.to_f / variants_count) * 30).to_i
      update_progress(progress, "Set inventory for: #{variant.display_name}")
    end
  end

  def generate_orders
    variants = Variant.joins(:product).where(products: { store_id: @store.id }).to_a
    return if variants.empty?

    customer_names = [
      %w[John Smith], %w[Jane Doe], %w[Robert Johnson],
      %w[Emily Williams], %w[Michael Brown], %w[Sarah Davis],
      %w[David Miller], %w[Jessica Wilson], %w[Chris Moore],
      %w[Amanda Taylor]
    ]

    cities = [
      ['San Francisco', 'CA', '94102'], ['New York', 'NY', '10001'],
      ['Los Angeles', 'CA', '90001'], ['Chicago', 'IL', '60601'],
      ['Seattle', 'WA', '98101']
    ]

    15.times do |i|
      name = customer_names.sample
      city = cities.sample

      order = @store.orders.create!(
        email: "#{name[0].downcase}.#{name[1].downcase}@example.com",
        status: %w[pending confirmed].sample,
        fulfillment_status: 'unfulfilled',
        financial_status: 'paid',
        shipping_address: {
          first_name: name[0],
          last_name: name[1],
          address1: "#{rand(100..9999)} #{%w[Main Oak Pine Elm Maple].sample} St",
          city: city[0],
          province: city[1],
          zip: city[2],
          country: 'US'
        },
        created_at: rand(0..14).days.ago
      )

      # Add line items
      rand(1..4).times do
        variant = variants.sample
        order.line_items.create!(
          variant: variant,
          quantity: rand(1..3)
        )
      end

      order.calculate_totals
      order.save!

      progress = 70 + ((i.to_f / 15) * 30).to_i
      update_progress(progress, "Created order: #{order.order_number}")
    end
  end

  def update_progress(step, message)
    @current_step = step
    broadcast_progress(message)
  end

  def broadcast_progress(message, completed: false)
    CartifySchema.subscriptions.trigger(
      :sync_progress_updated,
      { store_id: @store.id },
      {
        store_id: @store.id,
        job_id: @job_id,
        status: completed ? 'completed' : 'in_progress',
        progress: @current_step,
        total: @total_steps,
        message: message,
        completed_at: completed ? Time.current : nil
      }
    )
  end
end
