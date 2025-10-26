# Rails on Tap - Android App

A Hotwire Native Android application for the Rails on Tap kegerator management system. This app allows users to record pours and capture photos of people using the taps.

## Features

- **Record Pours**: Log beer pours with duration and volume
- **Capture Photos**: Take pictures of the person pouring
- **Real-time Updates**: Hotwire enables live updates from the Rails backend
- **Mobile-First UI**: Built with Hotwire Native for smooth native performance

## Prerequisites

- Android Studio (latest version)
- Kotlin 1.9+
- Android SDK 24+
- Java 11+
- Rails on Tap server running locally or remotely

## Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/rails-on-tap-android.git
   cd rails-on-tap-android
   ```

2. **Open in Android Studio**
   - Select "Open an existing Android Studio project"
   - Navigate to the `rails-on-tap-android` directory

3. **Configure Server URL**
   - Edit `MainActivity.kt`
   - Update `startLocation` to point to your Rails on Tap server
   - For local development: `http://localhost:3000` (requires Android emulator network configuration)
   - For production: `https://yourdomain.com`

4. **Build the App**
   ```bash
   ./gradlew build
   ```

5. **Run on Emulator or Device**
   ```bash
   ./gradlew installDebug
   ```

## Project Structure

```
rails-on-tap-android/
├── AndroidManifest.xml           # App permissions and configuration
├── MainActivity.kt               # Main Hotwire Native activity
├── nav_graph.xml                 # Navigation configuration
├── activity_main.xml             # Main activity layout
├── build.gradle                  # Dependencies and build config
└── README.md                      # This file
```

## Key Dependencies

- **Hotwire Android**: Native Android wrapper for Hotwire
- **OkHttp**: HTTP client for Rails API communication
- **Picasso**: Image loading and caching
- **Material Design**: UI components

## Usage

### Recording a Pour
1. Tap on a keg to select it
2. The app starts recording the pour duration
3. Release to stop recording
4. The pour data is sent to the Rails server

### Taking Pictures
1. From the pour screen, tap the camera button
2. Take a photo of the person pouring
3. The image is automatically uploaded to the server
4. A link to the photo is added to the pour record

## Configuration

### Server URL
Update the server URL in `MainActivity.kt`:
```kotlin
override val startLocation: URL
    get() = URL("http://your-server-url:3000")
```

### Permissions
The app requires these permissions (already configured in AndroidManifest.xml):
- `INTERNET` - Connect to Rails server
- `CAMERA` - Take photos
- `WRITE_EXTERNAL_STORAGE` - Save photos
- `READ_EXTERNAL_STORAGE` - Access photos

### Network Security
For development with HTTP (not HTTPS), the manifest includes:
```xml
android:usesCleartextTraffic="true"
```

## API Integration

The Android app communicates with the Rails on Tap server via JSON APIs. All API requests require authentication using an API key.

### Authentication
Include your API key in the `X-API-Key` header:
```kotlin
headers["X-API-Key"] = "your-api-key-here"
```

### Available Endpoints

#### Get Taps
```
GET /api/v1/taps
```
Returns a list of all available taps with current keg information.

Response:
```json
[
  {
    "id": 1,
    "name": "Tap 1",
    "position": 0,
    "keg": {
      "id": 1,
      "name": "Brew #42",
      "beverage_id": 5,
      "status": "active",
      "initial_volume": 1000,
      "final_volume": 750
    }
  }
]
```

#### Get Specific Tap
```
GET /api/v1/taps/:id
```

#### Get Kegs
```
GET /api/v1/kegs
```
Returns a list of all kegs with beverage information.

Response:
```json
[
  {
    "id": 1,
    "name": "Brew #42",
    "status": "active",
    "beverage": {
      "id": 5,
      "name": "IPA",
      "style": "India Pale Ale",
      "abv": 6.5
    }
  }
]
```

#### Record a Pour
```
POST /api/v1/drinks
Content-Type: application/json

{
  "tap_name": "Tap 1",
  "ticks": 100,
  "volume_ml": 355,
  "username": "john_doe",
  "duration": 10,
  "shout": "Cheers!"
}
```

Returns:
```json
{
  "id": 42,
  "user_id": 1,
  "drink_id": null,
  "tap_name": "Tap 1",
  "volume_ml": 355,
  "time": "2024-01-15T14:30:00Z"
}
```

#### Upload Picture
```
POST /api/v1/pictures
Content-Type: multipart/form-data

Parameters:
- image: (binary file) - The photo to upload
- drink_id: (optional) - Associate with a pour record
- keg_id: (optional) - Associate with a keg
- caption: (optional) - Description of the photo
- username: (optional) - Name of the user/person in photo
```

Returns:
```json
{
  "id": 10,
  "user_id": 1,
  "drink_id": 42,
  "keg_id": 1,
  "caption": "First pour!",
  "time": "2024-01-15T14:30:00Z",
  "image_url": "https://rails-on-tap.example.com/rails/active_storage/blobs/..."
}
```

## Development

### Local Server Connection
To connect to a Rails on Tap server running on your development machine:

1. **Android Emulator**:
   ```
   Use: http://10.0.2.2:3000
   ```
   (10.0.2.2 is a special alias for localhost from the Android emulator)

2. **Physical Device on Same Network**:
   ```
   Use: http://<your-machine-ip>:3000
   Find your IP with: ifconfig | grep "inet "
   ```

### Building and Testing
```bash
# Build debug APK
./gradlew assembleDebug

# Run unit tests
./gradlew test

# Run connected device tests
./gradlew connectedAndroidTest
```

## API Key Management

To get an API key from the Rails on Tap dashboard:
1. Navigate to `/admin/api_keys`
2. Click "New API Key"
3. Give it a descriptive name (e.g., "Android App")
4. Copy the key and store it securely in your app
Remove this for production and use HTTPS only.

## Building for Release

1. Update version in `build.gradle`
2. Create a signed release APK:
   ```bash
   ./gradlew assembleRelease
   ```
3. Sign with your release keystore
4. Upload to Google Play Store

## Troubleshooting

### App won't connect to server
- Ensure Rails on Tap server is running
- Check network connectivity
- Verify server URL in MainActivity.kt
- For emulator, use `10.0.2.2` instead of `localhost` to reach host machine

### Camera not working
- Grant camera permissions to the app
- Check `<uses-permission android:name="android.permission.CAMERA" />`
- Ensure device has a camera

### Image upload fails
- Verify storage permissions are granted
- Check file permissions on server
- Ensure rails server is accepting multipart uploads

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

Same as Rails on Tap project

## Support

For issues and feature requests, visit: https://github.com/yourusername/rails-on-tap/issues
