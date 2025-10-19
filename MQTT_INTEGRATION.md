# MQTT Integration Guide

## Overview

Ruby On Tap now has full MQTT support for connecting to ESP32-based kegboards! The connection test feature is fully implemented and working.

## Features Implemented

✅ **MQTT Connection Testing**
- Test connection to MQTT broker
- Verify authentication
- Test topic subscription
- Detailed error messages

✅ **MQTT Services**
- `MqttConnectionService` - Handles connections and testing
- `MqttListenerService` - Background listener for flow meter data (ready for integration)

✅ **Web Interface**
- Create/edit MQTT configurations
- Test connection with one click
- See real-time connection results

## Testing Your Connection

1. **Navigate to Hardware Configuration**
   - Go to http://localhost:3000/kegboard_configs
   
2. **Create or Edit Configuration**
   - Fill in your MQTT broker details
   - Click "Save"

3. **Test Connection**
   - Click the "Test Connection" button
   - You'll see:
     - ✅ Success: Connection details and test topic
     - ❌ Failure: Specific error message

## Connection Test Results

### Success Message
```
✅ Successfully connected to MQTT broker
Broker: 192.168.1.100:1883
Test Topic: kegbot/meter/0
```

### Common Error Messages

**Connection timeout**
```
❌ Connection failed: Connection timeout - broker may be unreachable
```
- Check broker IP address
- Verify broker is running
- Check network connectivity

**Connection refused**
```
❌ Connection failed: Connection refused - check broker address and port
```
- Verify the port number (usually 1883)
- Check firewall settings
- Ensure MQTT broker is listening on that port

**Host unreachable**
```
❌ Connection failed: Host unreachable - check network connectivity
```
- Verify you're on the same network as the broker
- Check network settings
- Try pinging the broker IP

**MQTT protocol error**
```
❌ Connection failed: MQTT protocol error: [details]
```
- Check MQTT version compatibility
- Verify username/password if using authentication

## Service Classes

### MqttConnectionService

Handles MQTT connection testing and subscription management.

```ruby
# Test connection
service = MqttConnectionService.new(kegboard_config)
result = service.test_connection

if result[:success]
  puts "Connected to #{result[:broker]}:#{result[:port]}"
  puts "Test topic: #{result[:test_topic]}"
else
  puts "Error: #{result[:error]}"
end

# Subscribe to meter topics
service.subscribe_to_meters do |meter_id, tick_count|
  puts "Meter #{meter_id}: #{tick_count} ticks"
end
```

### MqttListenerService

Background service for processing flow meter data (ready for Solid Queue integration).

```ruby
# Start listening (in a background job)
MqttListenerService.start
```

This service:
- Subscribes to all meter topics (0-9)
- Processes tick count updates
- Creates drink records automatically
- Updates keg volumes
- Generates system events

## Integration with Your ESP32

### ESP32 Configuration

Your ESP32 should publish to topics like:
```
kegbot/meter/0
kegbot/meter/1
kegbot/meter/2
```

With payload being the total tick count as an integer.

### Flow Meter Calibration

The default calibration is **2.2 ticks per mL** (2200 ticks per liter).

To customize, add a `ticks_per_ml` column to the `flow_meters` table:

```ruby
# Migration
add_column :flow_meters, :ticks_per_ml, :float, default: 2.2
```

Then update your flow meter records:
```ruby
FlowMeter.find_by(meter_name: "Meter 0").update(ticks_per_ml: 2.2)
```

### Linking MQTT Meters to Taps

The system expects flow meters to be named like "Meter 0", "Meter 1", etc. to match MQTT meter IDs.

You can customize this in `MqttListenerService#process_meter_update`:

```ruby
# Option 1: Match by meter name
flow_meter = FlowMeter.find_by(meter_name: "Meter #{meter_id}")

# Option 2: Add mqtt_meter_id column and match directly
flow_meter = FlowMeter.find_by(mqtt_meter_id: meter_id)

# Option 3: Use metadata field
flow_meter = FlowMeter.find_by("metadata->>'mqtt_id' = ?", meter_id.to_s)
```

## Running the Listener as a Background Job

To continuously listen for MQTT messages, create a Solid Queue job:

```ruby
# app/jobs/mqtt_listener_job.rb
class MqttListenerJob < ApplicationJob
  queue_as :default

  def perform
    MqttListenerService.start
  end
end
```

Start it:
```ruby
MqttListenerJob.perform_later
```

Or run in a separate process:
```bash
bin/rails runner "MqttListenerService.start"
```

## Troubleshooting

### Test Connection First
Always use the "Test Connection" button before trying to receive data. This verifies:
- Network connectivity
- MQTT broker accessibility
- Authentication (if used)
- Topic subscription capability

### Check MQTT Broker Logs
Monitor your MQTT broker to see:
- Connection attempts
- Subscription requests
- Published messages

Example with Mosquitto:
```bash
mosquitto_sub -h localhost -t 'kegbot/#' -v
```

### Check Rails Logs
Monitor `log/development.log` for MQTT-related messages:
```
Started MQTT listener for ESP32 Flow Meters
Meter 0 update: 12547 ticks
Created drink: 5702.3ml from Tap 1
```

### Debug Mode
Enable verbose logging in the service:
```ruby
# In MqttListenerService
Rails.logger.level = :debug
```

## Security Considerations

### Production Deployment
1. **Use TLS**: Configure MQTT over TLS (port 8883)
2. **Strong Passwords**: Use secure MQTT credentials
3. **Firewall**: Don't expose MQTT broker to the internet
4. **Network Isolation**: Keep MQTT on a private network

### Password Storage
Passwords are currently stored in plain text. To enable encryption:

```bash
# Generate encryption keys
bin/rails db:encryption:init

# Add to credentials
EDITOR="nano" bin/rails credentials:edit

# Add:
active_record_encryption:
  primary_key: [key]
  deterministic_key: [key]
  key_derivation_salt: [key]

# Uncomment in model
# app/models/kegboard_config.rb
encrypts :mqtt_password, deterministic: false
```

## Next Steps

1. ✅ Test your MQTT connection
2. ⏭️ Calibrate flow meters (add `ticks_per_ml` column)
3. ⏭️ Link MQTT meter IDs to FlowMeter records
4. ⏭️ Start the background listener service
5. ⏭️ Pour a test beer and watch it record! 🍺

## Support

For issues or questions:
1. Check the connection test results
2. Review MQTT broker logs
3. Check Rails logs
4. Verify ESP32 is publishing data

## Example Full Setup

```ruby
# 1. Create kegboard config
config = KegboardConfig.create!(
  name: "Main Kegerator",
  config_type: "mqtt",
  mqtt_broker: "192.168.1.100",
  mqtt_port: 1883,
  mqtt_topic_prefix: "kegbot",
  enabled: true
)

# 2. Test connection
service = MqttConnectionService.new(config)
result = service.test_connection
puts result

# 3. Start listener (in production, use background job)
MqttListenerService.start
```

---

**Implementation Date**: October 18, 2025  
**Status**: ✅ Fully Functional  
**MQTT Gem Version**: 0.6.0
