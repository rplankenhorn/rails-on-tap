# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Skip seed data if SKIP_SEED_DATA environment variable is set
if ENV["SKIP_SEED_DATA"] == "true"
  puts "⏭️  Skipping seed data (SKIP_SEED_DATA=true)"
  exit 0
end

# Create default site settings
site = KegbotSite.find_or_create_by(name: "default") do |s|
  s.title = "Rails on Tap"
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

# Create example kegboard configuration (commented out - user should configure with their own settings)
# KegboardConfig.find_or_create_by(name: "ESP32 Flow Meters") do |config|
#   config.config_type = "mqtt"
#   config.mqtt_broker = "192.168.1.100"  # Change to your MQTT broker
#   config.mqtt_port = 1883
#   config.mqtt_username = ""  # Optional
#   config.mqtt_password = ""  # Optional
#   config.mqtt_topic_prefix = "kegbot"
#   config.enabled = true
# end
# puts "✓ Example kegboard configuration created"

puts "\n" + "=" * 50
puts "Seed data created successfully!"
puts "=" * 50
puts "\nYou can now:"
puts "  1. Visit http://localhost:3000"
puts "  2. Login with username: admin, password: password"
puts "  3. Use API key: #{api_key.key}"
puts "  4. Configure your hardware at http://localhost:3000/kegboard_configs"
puts "\n⚠️  Remember to change the admin password!"

# Create test users with profile pictures and drinks
puts "\n" + "=" * 50
puts "Creating test data with pictures..."
puts "=" * 50

# Create test users
test_users = [
  { username: "johndoe", email: "john@example.com", display_name: "John Doe" },
  { username: "janedoe", email: "jane@example.com", display_name: "Jane Doe" },
  { username: "bobsmith", email: "bob@example.com", display_name: "Bob Smith" }
]

users = test_users.map do |user_data|
  User.find_or_create_by(username: user_data[:username]) do |u|
    u.email = user_data[:email]
    u.password = "password123"
    u.password_confirmation = "password123"
    u.display_name = user_data[:display_name]
    u.is_active = true
    u.is_staff = false
  end
end

puts "✓ Test users created (password: password123)"

# Create placeholder images for profile pictures
require 'net/http'
require 'uri'

def create_placeholder_image(text, color)
  # Create a simple placeholder using data URI
  # In production, you'd want to download real images
  # For now, we'll create a simple text-based image using SVG
  svg = <<~SVG
    <svg width="200" height="200" xmlns="http://www.w3.org/2000/svg">
      <rect width="200" height="200" fill="#{color}"/>
      <text x="50%" y="50%" font-family="Arial" font-size="60" fill="white"#{' '}
            text-anchor="middle" dominant-baseline="middle">#{text}</text>
    </svg>
  SVG

  StringIO.new(svg)
end

# Attach profile pictures to test users
colors = [ "#3498db", "#e74c3c", "#27ae60" ]
users.each_with_index do |user, index|
  unless user.mugshot_image.attached?
    initial = user.username[0].upcase
    img = create_placeholder_image(initial, colors[index])
    user.mugshot_image.attach(
      io: img,
      filename: "#{user.username}_avatar.svg",
      content_type: "image/svg+xml"
    )
    puts "  ✓ Profile picture attached for #{user.display_name}"
  end
end

# Create test drinks and sessions
active_kegs = Keg.joins(:keg_tap).where.not(keg_taps: { id: nil })

if active_kegs.any?
  # Create a drinking session
  session = DrinkingSession.create!(
    name: "Friday Night Session",
    start_time: 2.hours.ago,
    end_time: Time.current,
    volume_ml: 0
  )
  puts "✓ Created test drinking session"

  # Create drinks for each user
  drinks_created = []
  users.each_with_index do |user, index|
    keg = active_kegs.sample

    # Create 2-3 drinks per user
    rand(2..3).times do |drink_num|
      drink = Drink.create!(
        user: user,
        keg: keg,
        drinking_session: session,
        time: (120 - (index * 30) - (drink_num * 10)).minutes.ago,
        volume_ml: rand(300..500),
        ticks: rand(660..1100), # Based on ~2.2 ticks/ml
        duration: rand(10..30)
      )
      drinks_created << drink

      # Update session volume
      session.update(volume_ml: session.volume_ml + drink.volume_ml)

      puts "  ✓ Created drink for #{user.display_name}"
    end
  end

  # Create pictures for some drinks
  drinks_with_pictures = drinks_created.sample(5)

  drinks_with_pictures.each_with_index do |drink, index|
    # Create placeholder beer image
    beer_colors = [ "#F5A623", "#D4A024", "#CC8800", "#CC7700", "#D9A021" ]
    svg = <<~SVG
      <svg width="400" height="400" xmlns="http://www.w3.org/2000/svg">
        <rect width="400" height="400" fill="#2c3e50"/>
        <ellipse cx="200" cy="200" rx="80" ry="120" fill="#{beer_colors[index]}"/>
        <ellipse cx="200" cy="150" rx="80" ry="30" fill="#FFFFFF" opacity="0.9"/>
        <text x="200" y="350" font-family="Arial" font-size="20" fill="white"#{' '}
              text-anchor="middle">🍺 #{drink.keg.beverage.name}</text>
      </svg>
    SVG

    img = StringIO.new(svg)

    picture = Picture.new(
      user: drink.user,
      drink: drink,
      keg: drink.keg,
      drinking_session: drink.drinking_session,
      time: drink.time + rand(1..5).seconds,
      caption: [
        "Great pour!",
        "Cheers! 🍻",
        "Perfect head on this one",
        "Love this beer!",
        "Best #{drink.keg.beverage.name} yet!"
      ].sample
    )

    picture.image.attach(
      io: img,
      filename: "pour_#{drink.id}.svg",
      content_type: "image/svg+xml"
    )

    picture.save!

    puts "  ✓ Picture attached to drink ##{drink.id}"
  end

  puts "\n✓ Created #{drinks_created.count} drinks with #{drinks_with_pictures.count} pictures"
end

puts "\n" + "=" * 50
puts "Test data with pictures created!"
puts "=" * 50
puts "\nTest users (all password: password123):"
users.each do |user|
  puts "  - #{user.username} (#{user.display_name})"
end
puts "\nVisit these pages to see the pictures:"
puts "  📸 Pictures Gallery: http://localhost:3000/pictures"
puts "  👤 User Profile: http://localhost:3000/users/#{users.first.id}"
puts "  🍺 Drinks: http://localhost:3000/drinks"
puts "  🎉 Sessions: http://localhost:3000/sessions"
