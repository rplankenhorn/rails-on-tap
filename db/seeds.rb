# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create default site settings
site = KegbotSite.find_or_create_by(name: "default") do |s|
  s.title = "Ruby on Tap"
  s.is_setup = true
  s.server_version = "1.0.0"
  s.volume_display_units = "imperial"
  s.temperature_display_units = "f"
  s.privacy = "public"
  s.registration_mode = "public"
  s.timezone = "America/Los_Angeles"
  s.session_timeout_minutes = 180
  s.enable_sensing = true
  s.enable_users = true
end

puts "✓ Site settings created"

# Create guest user
guest = User.find_or_create_by(username: "guest") do |u|
  u.email = "guest@example.com"
  u.password = SecureRandom.hex(16)
  u.display_name = "Guest"
  u.is_active = true
  u.is_staff = false
end

puts "✓ Guest user created"

# Create admin user
admin = User.find_or_create_by(username: "admin") do |u|
  u.email = "admin@example.com"
  u.password = "password" # Change this!
  u.password_confirmation = "password"
  u.display_name = "Administrator"
  u.is_active = true
  u.is_staff = true
end

puts "✓ Admin user created (username: admin, password: password)"

# Create sample beverage producers
producers = [
  { name: "Sierra Nevada Brewing Co.", country: "US", origin_state: "California", origin_city: "Chico" },
  { name: "Stone Brewing", country: "US", origin_state: "California", origin_city: "Escondido" },
  { name: "Russian River Brewing Company", country: "US", origin_state: "California", origin_city: "Santa Rosa" },
  { name: "Lagunitas Brewing Company", country: "US", origin_state: "California", origin_city: "Petaluma" }
]

producers.each do |producer_data|
  BeverageProducer.find_or_create_by(name: producer_data[:name]) do |p|
    p.country = producer_data[:country]
    p.origin_state = producer_data[:origin_state]
    p.origin_city = producer_data[:origin_city]
    p.is_homebrew = false
  end
end

puts "✓ Sample beverage producers created"

# Create sample beverages
beverages = [
  {
    name: "Pale Ale",
    producer: "Sierra Nevada Brewing Co.",
    beverage_type: "beer",
    style: "American Pale Ale",
    abv_percent: 5.6,
    ibu: 38,
    color_hex: "#D4A024"
  },
  {
    name: "IPA",
    producer: "Stone Brewing",
    beverage_type: "beer",
    style: "American IPA",
    abv_percent: 6.9,
    ibu: 77,
    color_hex: "#CC8800"
  },
  {
    name: "Pliny the Elder",
    producer: "Russian River Brewing Company",
    beverage_type: "beer",
    style: "Double IPA",
    abv_percent: 8.0,
    ibu: 100,
    color_hex: "#CC7700"
  },
  {
    name: "IPA",
    producer: "Lagunitas Brewing Company",
    beverage_type: "beer",
    style: "American IPA",
    abv_percent: 6.2,
    ibu: 51.5,
    color_hex: "#D9A021"
  }
]

beverages.each do |bev_data|
  producer = BeverageProducer.find_by(name: bev_data[:producer])
  next unless producer

  Beverage.find_or_create_by(name: bev_data[:name], beverage_producer: producer) do |b|
    b.beverage_type = bev_data[:beverage_type]
    b.style = bev_data[:style]
    b.abv_percent = bev_data[:abv_percent]
    b.ibu = bev_data[:ibu]
    b.color_hex = bev_data[:color_hex]
  end
end

puts "✓ Sample beverages created"

# Create sample taps
3.times do |i|
  KegTap.find_or_create_by(name: "Tap #{i + 1}") do |t|
    t.sort_order = i
    t.notes = "Sample tap #{i + 1}"
  end
end

puts "✓ Sample taps created"

# Create hardware controller
controller = HardwareController.find_or_create_by(name: "kegboard") do |c|
  c.controller_model_name = "Kegboard"
  c.serial_number = "KB001"
end

puts "✓ Hardware controller created"

# Create flow meters for each tap
3.times do |i|
  tap = KegTap.find_by(name: "Tap #{i + 1}")
  meter = FlowMeter.find_or_create_by(controller: controller, port_name: "flow#{i}") do |m|
    m.ticks_per_ml = 2.2 # Default for FT330-RJ
  end
  meter.update(keg_tap: tap)
end

puts "✓ Flow meters created and assigned"

# Create sample kegs
beverages_for_kegs = Beverage.limit(2)
beverages_for_kegs.each_with_index do |beverage, index|
  # Skip if keg already exists for this beverage
  next if Keg.exists?(beverage: beverage, status: [ "on_tap", "available" ])

  keg = Keg.create!(
    beverage: beverage,
    keg_type: "half_barrel",
    served_volume_ml: 0,
    spilled_ml: 0,
    status: "available",
    start_time: Time.current,
    end_time: Time.current,
    description: "Sample keg of #{beverage.name}"
  )

  # Attach first two kegs to taps
  if index < 2
    tap = KegTap.find_by(name: "Tap #{index + 1}")
    tap.attach_keg!(keg) unless tap.active?
  end
end

puts "✓ Sample kegs created and attached to taps"

# Create API key for admin
api_key = admin.api_keys.find_or_create_by(active: true) do |key|
  key.key = ApiKey.generate_key
  key.description = "Admin API Key"
end

puts "✓ Admin API key created: #{api_key.key}"

puts "\n" + "=" * 50
puts "Seed data created successfully!"
puts "=" * 50
puts "\nYou can now:"
puts "  1. Visit http://localhost:3000"
puts "  2. Login with username: admin, password: password"
puts "  3. Use API key: #{api_key.key}"
puts "\n⚠️  Remember to change the admin password!"
