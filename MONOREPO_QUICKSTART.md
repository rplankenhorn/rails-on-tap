# 📱 Rails on Tap - Complete Monorepo Setup

## 🎉 What You Now Have

You have a **true monorepo** with both the Rails backend AND Android app in a single git repository. Everything is integrated and ready to run!

```
/Users/rplankenhorn/rails-on-tap/
├── 🚂 Rails Backend (Production-ready)
├── 📱 Android App (Hotwire Native)
├── 📚 Complete Documentation
└── 🔧 Developer Tools & Scripts
```

---

## 🚀 Getting Started - 3 Steps

### Step 1: One-Command Setup
```bash
cd /Users/rplankenhorn/rails-on-tap
./bin/quickstart
```

This interactive script will guide you through everything.

### Step 2: Start the Backend
```bash
make rails
```

Open http://localhost:3000 in your browser. ✓

### Step 3: Run the Android App

**Terminal 2**:
```bash
emulator -avd Pixel_6_API_31 &
```

**Terminal 3**:
```bash
cd android && ./gradlew run
```

App launches and connects to Rails! ✓

---

## 📖 What's in Your Monorepo

### Backend (Rails)
- **API Endpoints** at `/api/v1/`:
  - `POST /drinks` - Record pours
  - `POST /pictures` - Upload photos
  - `GET /taps`, `/kegs` - Tap/keg info
  - Full API docs in `API_MOBILE_INTEGRATION.md`

- **Web Dashboard** at `/`:
  - View drinks, pictures, taps, kegs
  - Admin panel
  - User management

- **Database**: SQLite3 (local development)

### Android App
- **Location**: `android/` directory
- **Technology**: Hotwire Native (Kotlin)
- **Connects to**: Rails via HTTP API
- **Features**:
  - Browse taps and kegs
  - Record pours
  - Capture photos
  - Real-time updates

### Documentation
| File | Purpose |
|------|---------|
| **START_HERE.md** | Quick reference (you are here!) |
| **RUNNING_EVERYTHING.md** | Complete run guide |
| **DEVELOPMENT.md** | Detailed dev environment |
| **API_MOBILE_INTEGRATION.md** | API reference for mobile |
| **Makefile** | Command shortcuts |

---

## 🛠️ Essential Commands

### Quick Commands (Using Makefile)
```bash
make help              # See all commands
make setup             # One-time setup
make rails             # Start Rails server
make android           # Start Android app
make test              # Run all tests
make logs              # View Rails logs
make db-console        # Open Rails console
make stop              # Stop everything
```

### Manual Commands
```bash
# Backend
bin/rails server              # Start Rails
bin/rails console             # Rails shell
bin/rails db:migrate          # Database

# Android
cd android && ./gradlew run   # Run app
cd android && ./gradlew test  # Run tests

# Docker
docker-compose up             # Full stack in Docker
```

---

## 🌐 Network URLs

### When Everything is Running

| Service | URL | Access From |
|---------|-----|-------------|
| Rails Dashboard | http://localhost:3000 | Browser |
| Admin Panel | http://localhost:3000/admin | Browser |
| API Base | http://localhost:3000/api/v1 | Android App |
| Android App | - | Emulator |

### Android to Rails Connection

**From Emulator** (special magic IP):
```
http://10.0.2.2:3000
```

**From Physical Device**:
```
Get your IP: ifconfig | grep "inet " | grep -v 127
http://YOUR_IP:3000
```

This is configured in `android/app/src/main/kotlin/MainActivity.kt`

---

## 📦 What You Get

### ✅ Complete Backend
- Rails 8.0.3 REST API
- SQLite3 database with proper schema
- User authentication (Devise)
- Active Storage for images
- API key authentication
- Admin dashboard
- Full model structure

### ✅ Complete Android App
- Hotwire Native wrapper
- Kotlin code
- AndroidManifest with permissions
- Gradle build system
- Pre-configured for localhost/network APIs
- Ready to build and deploy

### ✅ Developer Tools
- Makefile with 20+ commands
- Interactive quickstart script
- Complete documentation
- Setup scripts
- Comprehensive guides

### ✅ Git-Ready
- Single repository for everything
- No need to manage multiple repos
- Clone once, you have backend AND mobile
- Easy to share, deploy, collaborate

---

## 🔄 Development Workflow

### Typical Development Session

```bash
# Terminal 1: Start Rails
make rails

# Terminal 2: Start Android emulator
emulator -avd Pixel_6_API_31 &
sleep 10  # Wait for boot

# Terminal 3: Run Android app
cd android && ./gradlew run

# Terminal 4 (optional): Watch logs
make logs  # or: adb logcat | grep railsontap
```

All three services run independently but can communicate via the API.

### Making Changes

**Backend Changes**:
- Edit files in `app/`
- Rails auto-reloads
- Refresh browser

**Android Changes**:
- Edit files in `android/app/src/`
- Rebuild: `cd android && ./gradlew build`
- Or rebuild + run from Android Studio

---

## 🔑 API Keys & Authentication

### Generate an API Key

```bash
make db-console
```

In Rails console:
```ruby
key = ApiKey.create!(name: "My Dev Key")
puts key.token  # Copy this
```

### Use It in Android

Update `android/app/src/main/kotlin/MainActivity.kt`:
```kotlin
const val API_KEY = "your-copied-token-here"
```

Or in API calls:
```kotlin
request.addHeader("X-API-Key", API_KEY)
```

---

## 🧪 Testing

### Backend Tests
```bash
make test                    # All tests
make test-models            # Just models
bin/rails test test/models/drink_test.rb  # Specific
```

### Android Tests
```bash
cd android
./gradlew test              # Unit tests
./gradlew connectedAndroidTest  # Integration tests
```

### Manual API Testing
```bash
# Get all taps
curl -X GET "http://localhost:3000/api/v1/taps" \
  -H "X-API-Key: your-key"

# Record a pour
curl -X POST "http://localhost:3000/api/v1/drinks" \
  -H "X-API-Key: your-key" \
  -H "Content-Type: application/json" \
  -d '{"tap_name":"Tap 1","ticks":100,"volume_ml":355}'
```

---

## 🐛 Troubleshooting

### Rails Won't Start
```bash
# Port already in use?
lsof -i :3000

# Database problem?
bin/rails db:create db:migrate

# Gems not installed?
bundle install
```

### Android Won't Connect to API
```bash
# Wrong URL? Should be:
# From Emulator: http://10.0.2.2:3000
# From Device: http://YOUR_IP:3000

# Is Rails running?
curl http://localhost:3000

# Check API key is set in code
grep -r "API_KEY" android/app/src/
```

### Emulator Won't Start
```bash
# List emulators
emulator -list-avds

# Create one if missing
emulator -create-avd -n Pixel_6_API_31 \
  -k "system-images;android-31;google_apis;x86_64"

# Try starting with more RAM
emulator -avd Pixel_6_API_31 -memory 4096
```

---

## 📚 Documentation Map

```
├── START_HERE.md                    ← Quick reference (this file)
├── RUNNING_EVERYTHING.md            ← Complete running guide
├── DEVELOPMENT.md                   ← Dev environment details
├── API_MOBILE_INTEGRATION.md        ← API endpoints & examples
├── MONOREPO_DEVELOPMENT.md          ← Monorepo structure
├── README.md                        ← Project overview
├── PICTURES.md                      ← Picture handling
└── MQTT_INTEGRATION.md              ← Hardware integration
```

**Pro Tip**: Start with `RUNNING_EVERYTHING.md` for the most complete guide.

---

## 🎯 Common Tasks

### I want to...

**Add a new API endpoint**
1. Create controller in `app/controllers/api/v1/`
2. Add route in `config/routes.rb`
3. Test with curl or Postman
4. Use in Android app

**Change database schema**
1. Create migration: `bin/rails g migration AddFieldToModel`
2. Edit migration file
3. Run: `bin/rails db:migrate`

**Add Android dependency**
1. Add to `android/build.gradle` in dependencies
2. Run: `cd android && ./gradlew sync`
3. Use in Kotlin code

**Deploy to production**
1. See `config/deploy.yml` (Kamal setup)
2. Follow deployment documentation
3. Android app can point to production URL

---

## 💡 Pro Tips

1. **Use Terminal multiplexing**: 
   ```bash
   # macOS terminal split, VS Code terminal, iTerm, Tmux, etc.
   # Keep Rails, emulator, and logs all visible at once
   ```

2. **Create shell aliases**:
   ```bash
   alias rails-dev='cd /Users/rplankenhorn/rails-on-tap && make rails'
   alias android-dev='cd /Users/rplankenhorn/rails-on-tap && make android'
   alias quickstart='cd /Users/rplankenhorn/rails-on-tap && ./bin/quickstart'
   ```

3. **Watch logs in real-time**:
   ```bash
   make logs                    # Rails logs
   adb logcat | grep railsontap  # Android logs
   ```

4. **Use Rails console**:
   ```bash
   make db-console
   > Drink.last
   > Picture.count
   > Tap.all.map { |t| "#{t.name}: #{t.keg&.name}" }
   ```

5. **Check database directly**:
   ```bash
   sqlite3 storage/development.sqlite3
   sqlite> SELECT COUNT(*) FROM drinks;
   ```

---

## ✨ Next Steps

### Immediate (Today)
- [ ] Run `./bin/quickstart`
- [ ] Start `make rails`
- [ ] Open http://localhost:3000
- [ ] Run Android app

### Short Term (This Week)
- [ ] Create API key
- [ ] Test recording a pour from Android
- [ ] Upload photos from Android
- [ ] Verify data appears in Rails dashboard

### Medium Term (This Month)
- [ ] Add custom fields to drinks/pictures
- [ ] Extend Android UI
- [ ] Add more API endpoints
- [ ] Write tests

### Production Readiness
- [ ] Deploy Rails to production
- [ ] Configure API authentication for production
- [ ] Build release APK for Android
- [ ] Set up CI/CD pipeline

---

## 🆘 Getting Help

1. **Quick answers**: Check `START_HERE.md` (you are here!)
2. **How to run stuff**: See `RUNNING_EVERYTHING.md`
3. **API details**: Check `API_MOBILE_INTEGRATION.md`
4. **Architecture**: See `MONOREPO_DEVELOPMENT.md`
5. **Dev setup**: Read `DEVELOPMENT.md`
6. **Stuck?**: Check Troubleshooting section above

---

## 🎉 That's It!

You now have:
- ✅ Complete Rails backend
- ✅ Complete Android app
- ✅ Full API integration
- ✅ Development tools & docs
- ✅ Everything in one git repo

**Time to build something awesome!** 🚀

---

## 📞 Quick Reference

```bash
# Setup & Run
./bin/quickstart          # Interactive setup
make rails               # Start backend
make android             # Start Android
make help                # All commands

# Development
make db-console          # Rails shell
make logs                # View logs
make test                # Run tests
make lint                # Code quality

# Utilities
make clean               # Clean artifacts
make stop                # Stop services
make ps                  # See processes
make api-key             # Generate API key
```

**Start here**: `./bin/quickstart` 👈
