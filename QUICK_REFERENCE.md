# Rails on Tap - Quick Reference

## 🚀 Getting Started

```bash
# Clone and setup
git clone https://github.com/rplankenhorn/rails-on-tap.git
cd rails-on-tap
bin/setup
```

## 📁 Directory Structure

```
rails-on-tap/              # Monorepo root
├── app/                   # Rails app (models, controllers, views)
├── android/               # Native Android app
├── config/                # Rails configuration
├── db/                    # Database & migrations
├── test/                  # Tests
└── public/                # Static files
```

## 🏃 Running Locally

### Terminal 1 - Backend
```bash
bin/rails s
# http://localhost:3000
```

### Terminal 2 - Android (Optional)
```bash
cd android
# Open in Android Studio
./gradlew installDebug
```

### Using Docker (Alternative)
```bash
docker-compose up
```

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| `README.md` | Project overview & features |
| `API_MOBILE_INTEGRATION.md` | REST API reference (15+ endpoints) |
| `MONOREPO_DEVELOPMENT.md` | Development workflows & best practices |
| `MONOREPO_STATUS.md` | Project status & structure |
| `android/README.md` | Android-specific setup |

## 🔑 API Key (Local Dev)

```bash
# Auto-generated during setup, or:
bin/rails console
ApiKey.find_by(name: 'Local Development').token

# Use in requests:
curl -H "X-API-Key: YOUR_KEY" http://localhost:3000/api/v1/drinks
```

## 💻 Common Commands

### Database
```bash
bin/rails db:create              # Create DB
bin/rails db:migrate             # Run migrations
bin/rails db:seed                # Load sample data
bin/rails db:reset               # Drop, create, migrate, seed
```

### Testing
```bash
bin/rails test                   # Run all tests
bin/rails test test/path/file    # Run specific test
```

### Code Quality
```bash
bin/rubocop                      # Lint check
bin/brakeman                     # Security audit
bundle audit                     # Dependency vulnerabilities
```

### Console & Debugging
```bash
bin/rails console                # Interactive console
bin/rails logs                   # View logs
```

## 🔌 Key API Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| `GET` | `/api/v1/taps` | List all taps |
| `GET` | `/api/v1/kegs` | List all kegs |
| `POST` | `/api/v1/drinks` | Record a pour |
| `GET` | `/api/v1/drinks` | Query pours |
| `POST` | `/api/v1/pictures` | Upload photo |

See [API_MOBILE_INTEGRATION.md](API_MOBILE_INTEGRATION.md) for full reference.

## 👤 Creating Users

### Via Console
```bash
bin/rails console
User.create!(
  username: 'admin',
  email: 'admin@example.com',
  password: 'password123'
)
```

### Via Web UI
1. Go to http://localhost:3000/users/sign_up
2. Fill in form and register
3. To make admin:
   ```bash
   bin/rails console
   user = User.find_by(username: 'admin')
   user.update(role: 'admin')
   ```

## 🧪 Testing

```bash
# Run all tests
bin/rails test

# Run specific file
bin/rails test test/models/drink_test.rb

# Run with verbose output
bin/rails test -- --verbose

# Android tests
cd android
./gradlew test
```

## 🐳 Docker

```bash
# Build image
docker build -t rails-on-tap .

# Run container
docker run -p 3000:3000 rails-on-tap

# Using compose
docker-compose up              # Start all
docker-compose up rails        # Just Rails
docker-compose logs -f         # Follow logs
docker-compose down            # Stop all
```

## 📱 Android Development

### Setup
```bash
cd android
# Open in Android Studio
# Android Studio auto-installs dependencies
```

### API Configuration
Edit `MainActivity.kt`:
```kotlin
override val startLocation: URL
    get() = URL("http://10.0.2.2:3000")  // Emulator
    // or: URL("http://192.168.1.100:3000")  // Device (find your IP)
```

### Build & Run
```bash
./gradlew build                # Build
./gradlew installDebug         # Install to emulator
```

## 🐛 Troubleshooting

### Port 3000 in use
```bash
lsof -i :3000
kill -9 <PID>
```

### Android can't reach backend
- Emulator: Use `http://10.0.2.2:3000`
- Device: Use machine IP (run `ifconfig | grep inet`)

### Database locked
```bash
rm db/*.sqlite3-*
bin/rails db:migrate
```

### Bundle/Dependencies issue
```bash
bundle install --quiet
yarn install --quiet
```

## 🎯 Development Workflow

```bash
# 1. Create feature branch
git checkout -b feature/my-feature

# 2. Make changes
# ... edit files ...

# 3. Run tests
bin/rails test
cd android && ./gradlew test && cd ..

# 4. Commit with scope
git commit -m "[api] add new endpoint"
# or
git commit -m "[android] fix camera issue"

# 5. Push and create PR
git push origin feature/my-feature
```

## 📊 Key Models

- **User** - System users with authentication
- **Tap** - Physical tap configuration
- **Keg** - Beer container with status
- **Drink** - Individual pour
- **Picture** - Photo with metadata
- **DrinkingSession** - Grouped pours
- **Beverage** - Beer type/style
- **ApiKey** - Authentication tokens

See `db/schema.rb` for full database schema.

## 🔗 Important URLs

| URL | Purpose |
|-----|---------|
| `http://localhost:3000` | Home page |
| `http://localhost:3000/admin` | Admin dashboard |
| `http://localhost:3000/api/v1` | API root |
| `http://localhost:3000/pictures` | Picture gallery |
| `http://localhost:3000/taps` | Tap management |
| `http://localhost:3000/kegs` | Keg management |

## 📞 Getting Help

1. Check the main [README.md](README.md)
2. Review [MONOREPO_DEVELOPMENT.md](MONOREPO_DEVELOPMENT.md)
3. Check [API_MOBILE_INTEGRATION.md](API_MOBILE_INTEGRATION.md)
4. Search [GitHub Issues](https://github.com/rplankenhorn/rails-on-tap/issues)
5. Open a new issue with details

## 🎉 Quick Setup Command

```bash
# One command to rule them all
bin/setup --skip-server

# Then in separate terminals:
bin/rails s        # Terminal 1: Backend
# Terminal 2: Use Android Studio for mobile
```

---

**Happy brewing! 🍺**
