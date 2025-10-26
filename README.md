# Rails on Tap

A comprehensive beer kegerator monitoring and management system with a Rails backend and native mobile apps.

**Rails on Tap** is a monorepo containing both the backend API server and native mobile applications for tracking beer consumption, managing multiple taps, monitoring temperature, and providing detailed analytics.

## 📚 Project Structure

This is a monorepo with the following structure:

```
rails-on-tap/
├── android/                    # Native Android app using Hotwire Native
│   ├── build.gradle
│   ├── AndroidManifest.xml
│   ├── MainActivity.kt
│   └── README.md
├── app/                        # Rails application code
│   ├── controllers/
│   ├── models/
│   ├── views/
│   ├── assets/
│   └── jobs/
├── config/                     # Rails configuration
├── db/                         # Database migrations and seeds
├── lib/                        # Lib code and Rake tasks
├── test/                       # Test suites
├── public/                     # Static files
├── Gemfile                     # Ruby dependencies
├── config.ru                   # Rack config
├── Dockerfile                  # Docker image for deployment
├── API_MOBILE_INTEGRATION.md   # Mobile API documentation
└── README.md                   # This file
```

## 🚀 Quick Start

### Backend (Rails API)

**Requirements:**
- Ruby 3.4.7
- SQLite3
- Node.js 18+

**Setup:**
```bash
# Install dependencies
bundle install
yarn install

# Create and initialize database
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed

# Start development server
bin/rails s
```

Server runs on `http://localhost:3000`

### Android App

**Requirements:**
- Android Studio (latest)
- Kotlin 1.9+
- Android SDK 24+
- JDK 11+

**Setup:**
```bash
cd android
# Open in Android Studio and build
./gradlew build

# Run on emulator
./gradlew installDebug
```

See [android/README.md](android/README.md) for detailed Android setup.

## 📱 Features

### Backend Features
- **Tap Management**: Create, configure, and manage multiple taps
- **Keg Tracking**: Monitor keg status, volume, and beverage info
- **Pour Recording**: Automatic logging of pours with duration and volume
- **User Management**: Devise-based authentication and user tracking
- **Picture Gallery**: Capture and store photos of people pouring
- **REST API**: Complete API for mobile and third-party integrations
- **Hardware Integration**: Support for flow meters, solenoids, and Kegboard controllers
- **Real-time Updates**: WebSocket support via Action Cable
- **Admin Dashboard**: Comprehensive management interface

### Mobile Features
- **Hotwire Native**: Native Android wrapper around Rails web views
- **Camera Integration**: Take and upload photos directly from mobile
- **Pour Recording**: Quick interface to log pours
- **Real-time Sync**: Automatic synchronization with backend
- **Offline Support**: Continue using app even without network connection
- **Native Performance**: Full native speed with Rails functionality

## 🔌 API Documentation

The backend provides a comprehensive REST API for mobile clients and integrations.

**Key Endpoints:**
- `POST /api/v1/drinks` - Record a pour
- `GET /api/v1/drinks` - Query pours
- `POST /api/v1/pictures` - Upload photos
- `GET /api/v1/taps` - List taps with current keg info
- `GET /api/v1/kegs` - List all kegs

See [API_MOBILE_INTEGRATION.md](API_MOBILE_INTEGRATION.md) for complete API documentation and examples.

## 🔑 Authentication

### Web UI
Uses Devise for user authentication:
```bash
# Create admin user
bin/rails console
User.create!(
  username: 'admin',
  email: 'admin@example.com',
  password: 'secure_password'
)
```

### API
Uses API key authentication:
1. Create API key via admin dashboard: `/admin/api_keys`
2. Include in requests: `X-API-Key: your-key-here`

See [API_MOBILE_INTEGRATION.md](API_MOBILE_INTEGRATION.md#authentication) for mobile authentication setup.

## ⚙️ Configuration

### Environment Variables
Create `.env` file in project root:

```env
# Server
RAILS_ENV=development
RAILS_PORT=3000
RAILS_HOST=localhost:3000

# Database
DB_FILE=db/development.sqlite3

# Storage
ACTIVE_STORAGE_SERVICE=local

# Optional: Hardware integration
KEGBOARD_HOST=192.168.1.100
KEGBOARD_PORT=8000
```

### Docker Deployment

```bash
# Build image
docker build -t rails-on-tap .

# Run container
docker run -p 3000:3000 \
  -v $(pwd)/storage:/app/storage \
  -e RAILS_ENV=production \
  rails-on-tap
```

## 📊 Database Schema

Key models:
- **User**: System users with authentication
- **Tap**: Physical tap configurations
- **Keg**: Beverage containers with status tracking
- **Drink**: Individual pours with user and timing info
- **Picture**: Photos associated with pours
- **DrinkingSession**: Grouped drinking events
- **Beverage**: Beer types and styles
- **HardwareController**: Device integrations (Kegboard, etc.)

See `db/schema.rb` for complete schema.

## 🧪 Testing

```bash
# Run all tests
bin/rails test

# Run specific test file
bin/rails test test/models/drink_test.rb

# Run with coverage
COVERAGE=true bin/rails test
```

## 📦 Deployment

### Using Kamal (Recommended)

```bash
# Deploy
bin/kamal deploy

# Monitor logs
bin/kamal logs
```

See `config/deploy.yml` for deployment configuration.

### Manual Deployment

```bash
# Precompile assets
bin/rails assets:precompile

# Run migrations
bin/rails db:migrate RAILS_ENV=production

# Start server
bundle exec puma -e production
```

## 🛠️ Development

### Code Quality
```bash
# Run RuboCop linter
bin/rubocop

# Run security checks
bin/brakeman
```

### Database Management
```bash
# Create database
bin/rails db:create

# Run migrations
bin/rails db:migrate

# Seed sample data
bin/rails db:seed

# Reset (careful!)
bin/rails db:reset
```

### Running Background Jobs
```bash
# In separate terminal
bin/jobs watch

# Or manually run jobs
bin/rails jobs:work
```

## 📚 Documentation

- [API Mobile Integration Guide](API_MOBILE_INTEGRATION.md) - REST API documentation
- [Android Setup](android/README.md) - Native Android app setup
- [Kegboard Configuration](KEGBOARD_CONFIG.md) - Hardware integration
- [MQTT Integration](MQTT_INTEGRATION.md) - IoT device integration
- [Picture Management](PICTURES.md) - Photo storage and display

## 🤝 Contributing

1. Create a feature branch: `git checkout -b feature/my-feature`
2. Make your changes and test thoroughly
3. Commit with clear messages: `git commit -m "Add feature"`
4. Push to branch: `git push origin feature/my-feature`
5. Open a Pull Request

## 📝 Version

- **Rails**: 8.0.3
- **Ruby**: 3.4.7
- **Node**: 18+
- **Android**: API 24+

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

## 🆘 Support & Troubleshooting

### Common Issues

**Port 3000 already in use:**
```bash
# Find process using port
lsof -i :3000

# Kill process
kill -9 <PID>
```

**Database locked error:**
```bash
# Remove stale SQLite lock files
rm db/*.sqlite3-*
bin/rails db:migrate
```

**Android emulator can't reach localhost:**
```bash
# Use this URL in Android app: http://10.0.2.2:3000
# Or find your machine IP: ifconfig | grep "inet "
```

For more help, check [GitHub Issues](https://github.com/rplankenhorn/rails-on-tap/issues) or open a new issue.

## 🎯 Roadmap

- [ ] iOS app using Hotwire Native
- [ ] Machine learning for pour predictions
- [ ] Advanced analytics dashboard
- [ ] Multi-location support
- [ ] Third-party integrations (Untappd, etc.)
- [ ] PWA (Progressive Web App) support

## 👨‍💻 Author

Built with ❤️ for beer enthusiasts everywhere.
