# Android App API Integration

## Overview
The Android app now connects to your Rails backend API to display real tap and pour data. The native UI fetches data from the Rails on Tap API endpoints.

## Configuration

### Environment Variables
The API key and base URL are stored in `.env` at the repository root (shared by both Rails and Android):

1. **Copy the example file:**
   ```bash
   cp .env.example .env
   ```

2. **Update `.env` with your values:**
   ```properties
   RAILS_API_KEY=your_api_key_here
   RAILS_API_BASE_URL=http://10.0.2.2:3000
   ```

3. **Generate an API key in Rails console** (if you don't have one):
   ```ruby
   device = Device.create!(name: "Android App")
   api_key = ApiKey.create!(device: device, description: "Android client")
   puts api_key.key
   ```

The Android build reads from the root `.env` file and exposes values via `BuildConfig`.

**Note:** The `.env` file is gitignored. Never commit it. Use `.env.example` as a template for other developers.

## What Was Added

### 1. Dependencies (`android/app/build.gradle`)
- **Retrofit 2.9.0**: Modern HTTP client for Android
- **Gson Converter 2.9.0**: JSON serialization/deserialization
- **OkHttp**: Already included, used for HTTP logging

### 2. API Models (`com.railsontap.api.Models.kt`)
Kotlin data classes that match your Rails API responses:
- `TapResponse` - Tap data with keg, flow meter, hardware controller
- `KegResponse` - Keg information with beverage details
- `BeverageResponse` - Beverage name, style, ABV, producer
- `DrinkResponse` - Pour/drink records with user and keg info
- `UserResponse` - User information
- And more...

### 3. API Service (`com.railsontap.api.RailsApiService.kt`)
Retrofit interface defining API endpoints:
- `getTaps()` - Fetches all taps from `/api/v1/taps`
- `getDrinks(limit)` - Fetches recent drinks from `/api/v1/drinks`

### 4. API Client (`com.railsontap.api.ApiClient.kt`)
Singleton that configures Retrofit with credentials from `BuildConfig`:
- Base URL: `http://10.0.2.2:3000/` (Android emulator → localhost)
- HTTP logging for debugging
- 30-second timeouts
- Authorization header management

### 5. Updated TapListActivity
Now fetches real data:
- **Taps**: Shows only active kegs with beverage info and keg level
- **Recent Pours**: Displays last 20 pours with user, beverage, volume, time
- Error handling with Toast messages
- Logging for debugging

## Setup Instructions

### 1. Get an API Key

Your Rails app requires authentication. Generate an API key:

```bash
# In your Rails console
rails console

# Create an API key for the Android app
device = Device.create!(name: "Android App Device")
api_key = ApiKey.new(description: "Android App", active: true, user_id: User.first.id, device_id: device.id)
api_key.key = SecureRandom.hex(32)
api_key.save!
puts "API Key: #{api_key.key}"
```

Copy the token that's printed.

### 2. Configure API Key

**IMPORTANT**: The API key and base URL are now stored in `android/local.properties` which is **NOT** checked into version control.

1. Copy the example file:
   ```bash
   cd android
   cp local.properties.example local.properties
   ```

2. Edit `android/local.properties` and update:
   ```properties
   rails.api.key=paste_your_api_key_here
   rails.api.base.url=http://10.0.2.2:3000/
   ```

**Note**: `local.properties` is already in `.gitignore` and will not be committed to version control.

### 2. Update Base URL (for Real Device)

If testing on a real Android device instead of emulator, update `.env`:
```properties
# Replace 10.0.2.2 with your computer's IP address on local network
RAILS_API_BASE_URL=http://192.168.1.XXX:3000
```

Find your IP:
- macOS: `ifconfig | grep "inet " | grep -v 127.0.0.1`
- The IP will be something like `192.168.1.10`

### 3. Start Rails Server

```bash
cd /Users/rplankenhorn/rails-on-tap
rails server
```

### 4. Build and Install App

```bash
cd android
./gradlew assembleDebug
adb install app/build/outputs/apk/debug/app-debug.apk
```

Or use Android Studio to build and run.

## How It Works

### Loading Taps

1. App calls `ApiClient.apiService.getTaps()`
2. Rails returns JSON array of taps with nested keg/beverage data
3. App filters for `status == "on_tap"` (active kegs only)
4. Calculates percent full: `(initial_volume - final_volume) / initial_volume`
5. Displays in 2-column grid with progress bars

### Loading Recent Pours

1. App calls `ApiClient.apiService.getDrinks(limit = 20)`
2. Rails returns last 20 drinks with user/beverage info
3. App converts volume from mL to oz
4. Formats timestamps as relative time ("2m ago", "5h ago")
5. Displays in sidebar with placeholder for photos

## Data Flow

```
Android App (Kotlin)
    ↓ HTTP GET
ApiClient (Retrofit + OkHttp)
    ↓ Authorization: Bearer <token>
Rails API (api/v1/taps, api/v1/drinks)
    ↓ JSON Response
Gson Converter
    ↓ Kotlin Data Classes
TapListActivity
    ↓ UI Update
RecyclerView Adapters → Display
```

## Troubleshooting

### "Failed to load taps: 401"
- API key is invalid or expired
- Check `ApiClient.API_KEY` is set correctly
- Verify key exists: `ApiKey.find_by(token: "your_key")`

### "Error: Unable to resolve host"
- Rails server isn't running
- Wrong IP address in BASE_URL
- Emulator can't reach localhost (use 10.0.2.2)

### "Failed to load taps: 500"
- Check Rails logs: `tail -f log/development.log`
- Database might need migration
- Missing associations in Rails models

### App shows no taps
- No kegs with `status = "on_tap"`
- Check: `Tap.includes(:keg).where(kegs: { status: "on_tap" })`
- Create test data in Rails console

### Network Security Error
- `android:usesCleartextTraffic="true"` is already set in manifest
- Required for HTTP (non-HTTPS) in Android 9+

## API Endpoints Used

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/v1/taps` | GET | List all taps with keg info |
| `/api/v1/drinks?limit=20` | GET | Recent 20 pours |

## Next Steps

### 1. Photo Loading
Uncomment TODO in `RecentPoursAdapter.kt` to load actual pour photos using Picasso.

### 2. Pull to Refresh
Add SwipeRefreshLayout to `activity_tap_list.xml` to reload data.

### 3. Pour Recording
Implement camera capture and POST to `/api/v1/drinks` to record new pours.

### 4. Real-time Updates
Consider WebSocket/SSE to show new pours instantly without refresh.

### 5. Error States
Add empty states and retry buttons for better UX.

## Files Modified

- `android/app/build.gradle` - Added Retrofit dependencies
- `android/app/src/main/AndroidManifest.xml` - Already had INTERNET permission
- `android/app/src/main/java/com/example/railsontap/api/Models.kt` - NEW
- `android/app/src/main/java/com/example/railsontap/api/RailsApiService.kt` - NEW
- `android/app/src/main/java/com/example/railsontap/api/ApiClient.kt` - NEW
- `android/app/src/main/java/com/railsontap/TapListActivity.kt` - Updated to use API

## Testing Checklist

- [ ] Generate API key in Rails console
- [ ] Add API key to `ApiClient.kt`
- [ ] Start Rails server
- [ ] Build Android app
- [ ] Install on emulator or device
- [ ] Check tap list loads (shows active kegs)
- [ ] Check recent pours sidebar (shows last 20)
- [ ] Check logcat for any errors: `adb logcat | grep TapListActivity`
