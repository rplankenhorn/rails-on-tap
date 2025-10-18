# Ruby on Tap (Kegbot Rails Edition)

A comprehensive beer kegerator monitoring and management system built with Ruby on Rails, replicating the functionality of the [Kegbot Server](https://github.com/Kegbot/kegbot-server).

## Overview

Ruby on Tap is a complete kegerator monitoring solution that tracks beer consumption, manages multiple taps, monitors temperature, handles user authentication, and provides detailed analytics and statistics. Perfect for home bars, offices, or anywhere you want to track keg activity.

## Features

### Core Functionality
- **Multi-Tap Management**: Monitor and manage multiple beer taps simultaneously
- **Real-time Pour Tracking**: Record every drink with volume, duration, and user information
- **Keg Management**: Track kegs from tap to kick, including volume remaining and consumption rates
- **Session Tracking**: Automatically group drinks into drinking sessions
- **User Profiles**: Track individual user consumption and statistics
- **Temperature Monitoring**: Monitor tap temperatures with historical data

### Beverage Database
- **Beverage Catalog**: Comprehensive database of beers, wines, and other beverages
- **Producer Information**: Track breweries, wineries, and other producers
- **Beer Metadata**: ABV, IBU, SRM, style, calories, and more

### Hardware Integration
- **Flow Meters**: Support for electronic flow meters to measure pour volume
- **Flow Toggles**: Control tap valves electronically
- **Temperature Sensors**: Monitor keg and tap temperatures
- **RFID/OneWire**: Authenticate users with RFID cards or OneWire tokens
- **Multiple Controllers**: Support for multiple hardware controllers (Kegboard, etc.)

### Analytics & Statistics
- **Real-time Stats**: Live statistics for kegs, users, and sessions
- **Charts & Graphs**: Visual consumption trends and analytics
- **System Events**: Complete event log of all system activity
- **Leaderboards**: Top drinkers, fastest pours, and more

### API
- **RESTful API**: Complete API for mobile apps and integrations
- **API Key Authentication**: Secure API access with key-based auth
- **Pour Logging**: Remote drink recording from hardware devices
- **Data Access**: Query kegs, drinks, sessions, and statistics

### Administration
- **Site Settings**: Customize privacy, registration, units, timezone, and more
- **User Management**: Admin tools for user administration
- **Invitation System**: Control registration with invite codes
- **Notification Settings**: Configurable notifications for keg events

## Technology Stack

- **Framework**: Ruby on Rails 8.0
- **Database**: SQLite (easily swappable for PostgreSQL, MySQL)
- **Authentication**: Devise with API support
- **Image Processing**: Active Storage with ImageMagick/libvips
- **Frontend**: Hotwire (Turbo + Stimulus)
- **Charts**: Chartkick for analytics visualization
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache
- **Real-time**: Action Cable for live updates

## Installation

### Prerequisites
- Ruby 3.2+
- Rails 8.0+
- SQLite3 (or PostgreSQL/MySQL)
- ImageMagick or libvips (for image processing)

### Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/ruby-on-tap.git
cd ruby-on-tap
```

2. Install dependencies:
```bash
bundle install
```

3. Set up the database:
```bash
rails db:create
rails db:migrate
rails db:seed
```

4. Configure environment variables (create `.env` file):
```
RAILS_ENV=development
SECRET_KEY_BASE=your_secret_key_here
```

5. Start the server:
```bash
./bin/dev
```

6. Visit http://localhost:3000 and complete the setup wizard

## Database Models

### Core Models
- **User**: User accounts with authentication and profiles
- **Keg**: Physical kegs with volume tracking and status
- **KegTap**: Physical tap locations and current keg assignments
- **Beverage**: Beer/beverage information (name, style, ABV, etc.)
- **BeverageProducer**: Breweries, wineries, and other producers
- **Drink**: Individual pour records with user, volume, and timing
- **DrinkingSession**: Grouped drink sessions with automatic timeout

### Hardware Models
- **HardwareController**: Physical controllers (Kegboard, etc.)
- **FlowMeter**: Flow sensors for measuring pour volume
- **FlowToggle**: Electronic valves for controlling flow
- **ThermoSensor**: Temperature sensors
- **Thermolog**: Temperature reading history

### System Models
- **SystemEvent**: Complete audit log of all system activity
- **Picture**: Photos associated with drinks and sessions
- **Stat**: Computed statistics for various views
- **AuthenticationToken**: RFID/OneWire tokens for user auth
- **ApiKey**: API authentication keys
- **Device**: Registered hardware devices

### Configuration Models
- **KegbotSite**: Site-wide settings and configuration
- **Invitation**: Invite codes for user registration
- **NotificationSetting**: User notification preferences
- **PluginDatum**: Key-value storage for plugins

## API Usage

### Authentication
Include your API key in requests:
```bash
curl -H "X-API-Key: your_api_key_here" https://your-kegbot.com/api/v1/kegs
```

### Recording a Drink
```bash
POST /api/v1/drinks
{
  "tap_name": "kegboard.flow0",
  "ticks": 220,
  "volume_ml": 100.0,
  "username": "john",
  "duration": 5,
  "shout": "Delicious!"
}
```

### Getting Keg Status
```bash
GET /api/v1/kegs?status=on_tap
```

### Response Example
```json
[
  {
    "id": 1,
    "beverage": "Pliny the Elder by Russian River Brewing",
    "keg_type": "half_barrel",
    "status": "on_tap",
    "full_volume_ml": 58674,
    "served_volume_ml": 12500,
    "remaining_volume_ml": 46174,
    "percent_full": 78.7,
    "start_time": "2025-10-15T10:30:00Z",
    "end_time": "2025-10-15T10:30:00Z"
  }
]
```

## Hardware Integration

### Supported Hardware
- **Kegboard**: Official Kegbot Arduino-based controller
- **Generic Flow Meters**: Any pulse-output flow meter
- **DS18B20**: Temperature sensors
- **RFID Readers**: RC522 and compatible readers
- **OneWire**: DS2401 and compatible OneWire devices

### Hardware Setup
1. Connect flow meter to controller
2. Register controller in admin panel
3. Create tap and assign meter
4. Attach keg to tap
5. Start pouring!

### Flow Meter Calibration
Flow meters report ticks per unit volume. Default is 2.2 ticks/mL (FT330-RJ):
```ruby
meter = FlowMeter.find(1)
meter.update(ticks_per_ml: 5.4)  # For SF800
```

## Configuration

### Site Settings
Access via Admin → Site Settings or directly:
```ruby
site = KegbotSite.get
site.update(
  title: "My Awesome Kegbot",
  volume_display_units: "imperial",  # or "metric"
  temperature_display_units: "f",     # or "c"
  session_timeout_minutes: 180,       # 3 hours
  privacy: "public",                  # "members" or "staff"
  timezone: "America/Los_Angeles"
)
```

### User Registration
- **Public**: Anyone can register
- **Member Invite**: Existing members can invite
- **Staff Invite**: Only staff can invite

## Development

### Running Tests
```bash
rails test
rails test:system
```

### Code Style
```bash
bin/rubocop
```

### Database Console
```bash
rails console
rails dbconsole
```

### Creating Sample Data
```bash
rails db:seed
```

## Deployment

### Docker
```bash
docker build -t ruby-on-tap .
docker run -p 3000:3000 ruby-on-tap
```

### Kamal (Included)
```bash
kamal setup
kamal deploy
```

### Traditional Deployment
1. Set production environment variables
2. Precompile assets: `rails assets:precompile`
3. Run migrations: `rails db:migrate`
4. Start server with `rails server -e production`

## Monitoring & Maintenance

### Health Check
```bash
curl https://your-kegbot.com/up
```

### Database Backup
```bash
rails db:backup
```

### Clearing Old Data
Temperature logs older than 24 hours are automatically cleaned up.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by and compatible with [Kegbot Server](https://github.com/Kegbot/kegbot-server)
- Built with ❤️ and 🍺 by the Ruby community

## Support

- Documentation: https://docs.your-kegbot.com
- Issues: https://github.com/yourusername/ruby-on-tap/issues
- Discussions: https://github.com/yourusername/ruby-on-tap/discussions

## Roadmap

- [ ] Advanced statistics and analytics
- [ ] Mobile app integration
- [ ] Brewery database integration (Untappd, BreweryDB)
- [ ] Social features and photo sharing
- [ ] Multi-tenant support
- [ ] Bluetooth pour detection
- [ ] Voice assistant integration

---

**Cheers! 🍺**
