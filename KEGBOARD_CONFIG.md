# Kegboard Hardware Configuration Guide

## Overview

Ruby On Tap now includes a flexible hardware configuration system that allows you to connect flow meters and sensors via different methods. Currently, MQTT is fully supported (perfect for ESP32 boards), with Serial/USB support coming soon.

## Features

- **Web-based Configuration**: Configure your hardware connections through an easy-to-use web interface
- **MQTT Support**: Connect to ESP32 or similar devices publishing flow meter data via MQTT
- **Connection Testing**: Test your MQTT connection with one click to verify settings
- **Multiple Configurations**: Support for multiple kegboard configurations (useful for testing or multi-location setups)
- **Secure**: MQTT passwords can be encrypted in the database (optional)
- **Flexible Topic Naming**: Configure custom MQTT topic prefixes to match your setup

## Accessing the Configuration

1. Navigate to **Hardware** in the main navigation menu
2. Or visit: `http://localhost:3000/kegboard_configs`

## Setting Up ESP32 MQTT Integration

### Prerequisites

- An ESP32 board with flow meters connected (see your existing `kegboard/esp32.yaml` configuration)
- An MQTT broker (e.g., Mosquitto, Home Assistant, or cloud-based broker)
- Your ESP32 configured to publish to MQTT topics

### Configuration Steps

1. **Create a New Configuration**
   - Click "Add Configuration"
   - Give it a name (e.g., "Main Kegerator ESP32")
   
2. **MQTT Broker Settings**
   - **Broker Address**: IP address or hostname of your MQTT broker (e.g., `192.168.1.100`)
   - **Port**: Usually `1883` for standard MQTT, or `8883` for MQTT over TLS
   - **Username/Password**: Optional, if your broker requires authentication
   
3. **Topic Configuration**
   - **Topic Prefix**: Should match your ESP32 config (default: `kegbot`)
   - The system will subscribe to: `{prefix}/meter/0`, `{prefix}/meter/1`, `{prefix}/meter/2`, etc.

4. **Enable the Configuration**
   - Check the "Enable this configuration" box
   - Click "Create Configuration"

### Matching Your ESP32 Configuration

Your existing ESP32 configuration (`kegboard/esp32.yaml`) publishes to these topics:
```yaml
substitutions:
  meter_0_topic: "meter/0"
  meter_1_topic: "meter/1"
  meter_2_topic: "meter/2"

mqtt:
  broker: !secret mqtt_server
  username: !secret mqtt_user
  password: !secret mqtt_password
  topic_prefix: "kegbot"
```

Make sure your Ruby On Tap configuration matches:
- **MQTT Broker**: Same as `mqtt_server` in your ESP32 secrets
- **Username**: Same as `mqtt_user` (if used)
- **Password**: Same as `mqtt_password` (if used)
- **Topic Prefix**: Same as `topic_prefix` ("kegbot")

## How It Works

### Flow Meter Integration

1. **ESP32 Detects Pour**: When beer flows through a tap, the flow meter sends pulses to the ESP32
2. **Tick Counter Increments**: The ESP32 increments a persistent counter for that meter
3. **MQTT Publish**: When the count changes, the ESP32 publishes to `kegbot/meter/{N}` with the total tick count
4. **Ruby On Tap Receives**: Ruby On Tap subscribes to these topics and processes flow data
5. **Drink Recording**: The system calculates volume and creates drink records

### Data Flow Example

```
Flow Meter → ESP32 GPIO → Counter Increment → MQTT Publish
                                                    ↓
                                        kegbot/meter/0: "12547"
                                                    ↓
                                        Ruby On Tap MQTT Subscriber
                                                    ↓
                                        Calculate Volume (ticks × mL/tick)
                                                    ↓
                                        Create Drink Record
```

## Database Schema

The `kegboard_configs` table stores:

```ruby
{
  name: "Main ESP32",                 # Friendly name
  config_type: "mqtt",                # Connection type (mqtt, serial, usb)
  mqtt_broker: "192.168.1.100",       # MQTT broker address
  mqtt_port: 1883,                    # MQTT port
  mqtt_username: "kegbot",            # Optional authentication
  mqtt_password: "[encrypted]",       # Encrypted password
  mqtt_topic_prefix: "kegbot",        # Topic prefix
  enabled: true                       # Active/inactive
}
```

## API

### Configuration Model

```ruby
# Find active configuration
config = KegboardConfig.default

# Get MQTT URL
config.mqtt_url
# => "mqtt://username:password@192.168.1.100:1883"

# Get meter topic for flow meter ID
config.meter_topic(0)
# => "kegbot/meter/0"

config.meter_topic(1)
# => "kegbot/meter/1"
```

### Controller Actions

- `GET /kegboard_configs` - List all configurations
- `GET /kegboard_configs/new` - New configuration form
- `POST /kegboard_configs` - Create configuration
- `GET /kegboard_configs/:id/edit` - Edit configuration
- `PATCH /kegboard_configs/:id` - Update configuration
- `DELETE /kegboard_configs/:id` - Delete configuration
- `POST /kegboard_configs/:id/test_connection` - Test MQTT connection (coming soon)

## Next Steps (MQTT Service Implementation)

To complete the integration, you'll need to:

1. **Add MQTT gem**: Add `gem 'mqtt'` to your Gemfile
2. **Create MQTT Service**: Build a service to subscribe to flow meter topics
3. **Background Job**: Process incoming MQTT messages
4. **Link to Flow Meters**: Associate MQTT topics with FlowMeter records in the database

Example service structure:
```ruby
# app/services/mqtt_service.rb
class MqttService
  def self.connect
    config = KegboardConfig.enabled.mqtt.first
    return unless config
    
    # Connect to MQTT broker and subscribe to meter topics
    # Process incoming messages and record drinks
  end
end
```

## Troubleshooting

### Can't Connect to MQTT Broker
- Verify the broker IP/hostname is correct
- Check that the port is open (use `telnet <broker> 1883`)
- Ensure your Ruby On Tap server can reach the broker on the network
- Verify credentials if authentication is enabled

### Not Receiving Flow Data
- Check ESP32 is connected and publishing (`mosquitto_sub -h <broker> -t kegbot/meter/#`)
- Verify topic prefix matches between ESP32 and Ruby On Tap
- Check MQTT broker logs for connection/subscription errors

### Multiple Configurations
- Only one configuration should be enabled at a time
- The system uses `KegboardConfig.default` to find the active config

## Security Considerations

- **Password Encryption**: MQTT passwords are encrypted using Rails' ActiveRecord encryption
- **Network Security**: Consider using MQTT over TLS (port 8883) for production
- **Firewall**: Ensure MQTT port is not exposed to the internet unnecessarily
- **Authentication**: Use MQTT username/password authentication when possible

## Future Enhancements

- Serial/USB support for direct Arduino/Kegboard connections
- WebSocket API for real-time flow monitoring
- Connection testing and diagnostics
- Multiple simultaneous configurations (load balancing)
- MQTT topic discovery and auto-configuration
- Flow meter calibration interface

## Related Files

- Model: `app/models/kegboard_config.rb`
- Controller: `app/controllers/kegboard_configs_controller.rb`
- Views: `app/views/kegboard_configs/`
- Migration: `db/migrate/[timestamp]_create_kegboard_configs.rb`
- ESP32 Config: `kegboard/esp32.yaml`

---

**Created**: October 18, 2025  
**Rails Version**: 8.0.3  
**Ruby Version**: 3.4.7
