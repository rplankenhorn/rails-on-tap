# Rails on Tap - Mobile API Integration Guide

This document outlines the API endpoints available for the Hotwire Native Android app and other mobile clients.

## Overview

The Rails on Tap application provides a comprehensive REST API for mobile applications to:
- Record pours and drinking sessions
- Capture and upload photos
- Access keg and tap information
- Query drinking history

## Authentication

All API requests require an API key for authentication. Include it in the request header:

```
X-API-Key: your-api-key-here
```

### Creating an API Key

1. Log in to the Rails on Tap admin dashboard
2. Navigate to `/admin/api_keys`
3. Click "New API Key"
4. Give it a descriptive name (e.g., "Android App")
5. Copy the generated key immediately (it won't be shown again)

## Base URL

- **Development**: `http://localhost:3000` or `http://10.0.2.2:3000` (from Android emulator)
- **Staging**: `https://staging.rails-on-tap.example.com`
- **Production**: `https://rails-on-tap.example.com`

## API Endpoints

### Taps

#### Get All Taps
```
GET /api/v1/taps
```

Returns a list of all taps with their current keg and hardware status.

**Response**:
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
    },
    "flow_meter": {
      "id": 1,
      "name": "Flow Meter 1",
      "port": "meter_1"
    },
    "flow_toggle": {
      "id": 1,
      "name": "Solenoid 1",
      "port": "solenoid_1"
    },
    "updated_at": "2024-01-15T14:30:00Z"
  }
]
```

#### Get Tap Details
```
GET /api/v1/taps/:id
```

Returns detailed information about a specific tap.

### Kegs

#### Get All Kegs
```
GET /api/v1/kegs
```

Returns a list of all kegs with beverage information.

**Response**:
```json
[
  {
    "id": 1,
    "name": "Brew #42",
    "status": "active",
    "started_at": "2024-01-10T00:00:00Z",
    "initial_volume": 1000,
    "final_volume": 750,
    "beverage": {
      "id": 5,
      "name": "IPA",
      "style": "India Pale Ale",
      "abv": 6.5,
      "producer_id": 2
    },
    "updated_at": "2024-01-15T14:30:00Z"
  }
]
```

#### Get Keg Details
```
GET /api/v1/kegs/:id
```

Returns detailed information about a specific keg.

### Drinks (Pours)

#### Record a Pour
```
POST /api/v1/drinks
Content-Type: application/json
X-API-Key: your-api-key-here

{
  "tap_name": "Tap 1",
  "ticks": 100,
  "volume_ml": 355,
  "username": "john_doe",
  "duration": 10,
  "shout": "Cheers!"
}
```

**Parameters**:
- `tap_name` (required): Name or identifier of the tap being used
- `ticks` (required): Number of flow meter ticks recorded
- `volume_ml` (optional): Volume in milliliters (auto-calculated if not provided)
- `username` (optional): Name of the person pouring
- `duration` (optional): Duration of the pour in seconds
- `shout` (optional): Message or comment for the pour
- `pour_time` (optional): ISO 8601 timestamp of when the pour occurred

**Response**:
```json
{
  "id": 42,
  "user_id": 1,
  "tap_name": "Tap 1",
  "volume_ml": 355,
  "time": "2024-01-15T14:30:00Z"
}
```

#### Get Recent Pours
```
GET /api/v1/drinks?limit=50
```

Returns the most recent pours (default 50, customizable with limit parameter).

#### Get Pour Details
```
GET /api/v1/drinks/:id
```

Returns detailed information about a specific pour.

### Pictures

#### Upload Picture
```
POST /api/v1/pictures
Content-Type: multipart/form-data
X-API-Key: your-api-key-here

Form Data:
- image: (file) - JPEG, PNG, or WebP image
- drink_id: (optional, integer) - Associate with a pour record
- keg_id: (optional, integer) - Associate with a keg
- caption: (optional, string) - Description of the photo
- username: (optional, string) - Name associated with the photo
```

**Response**:
```json
{
  "id": 10,
  "user_id": 1,
  "drink_id": 42,
  "keg_id": 1,
  "caption": "First pour!",
  "time": "2024-01-15T14:30:00Z",
  "image_url": "https://rails-on-tap.example.com/rails/active_storage/blobs/abc123def456..."
}
```

**Image Requirements**:
- Maximum file size: 50 MB
- Supported formats: JPEG, PNG, WebP
- Minimum dimensions: 400x300 pixels
- Recommended dimensions: 1920x1440 pixels or higher

## Error Handling

All API errors follow a standard JSON format:

```json
{
  "error": "Error message describing what went wrong",
  "errors": ["Field name error message", "Another field error"]
}
```

### Status Codes

| Code | Meaning |
|------|---------|
| 200  | OK - Request successful |
| 201  | Created - Resource successfully created |
| 400  | Bad Request - Invalid parameters |
| 401  | Unauthorized - Missing or invalid API key |
| 404  | Not Found - Resource not found |
| 422  | Unprocessable Entity - Validation errors |
| 500  | Internal Server Error |

## Rate Limiting

API requests are rate-limited per API key:
- **Default limit**: 1000 requests per hour
- **Burst limit**: 50 requests per minute

When rate limited, the API responds with HTTP 429 status code.

## Connecting from Android

### For Local Development

From Android Emulator:
```kotlin
val apiUrl = "http://10.0.2.2:3000/api/v1"
```

From Physical Device on Same Network:
```kotlin
// Find your machine IP: ifconfig | grep "inet "
val apiUrl = "http://192.168.1.100:3000/api/v1"  // Replace with your IP
```

### Example Kotlin Code

```kotlin
import okhttp3.MediaType
import okhttp3.OkHttpClient
import okhttp3.Request
import okhttp3.RequestBody

val client = OkHttpClient()

// Add API key to all requests
val apiKey = "your-api-key-here"
val request = Request.Builder()
    .url("http://10.0.2.2:3000/api/v1/drinks")
    .addHeader("X-API-Key", apiKey)
    .addHeader("Content-Type", "application/json")
    .post(RequestBody.create(
        MediaType.parse("application/json"),
        """{
            "tap_name": "Tap 1",
            "ticks": 100,
            "volume_ml": 355,
            "username": "john_doe"
        }""".toByteArray()
    ))
    .build()

val response = client.newCall(request).execute()
```

## Webhook Events (Future Feature)

In future versions, the API will support webhooks for real-time notifications when:
- A new pour is recorded
- A photo is uploaded
- A keg is attached or detached
- A new drinking session starts

## Client Libraries

### Swift (iOS)
```bash
pod 'Rails-on-Tap-SDK'
```

### Kotlin (Android)
```gradle
implementation 'com.railsontap:sdk:1.0.0'
```

### JavaScript/TypeScript
```bash
npm install rails-on-tap-sdk
```

## Support

For API issues or questions:
- Check the [main README](README.md)
- Visit the [GitHub Issues](https://github.com/yourusername/rails-on-tap/issues)
- Contact the development team
