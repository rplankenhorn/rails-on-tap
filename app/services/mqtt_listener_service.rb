class MqttListenerService
  def self.start
    new.start
  end

  def start
    config = KegboardConfig.enabled.mqtt.first

    unless config
      Rails.logger.warn "No enabled MQTT kegboard configuration found"
      return
    end

    Rails.logger.info "Starting MQTT listener for #{config.name}"
    service = MqttConnectionService.new(config)

    # Subscribe and process messages
    service.subscribe_to_meters do |meter_id, tick_count|
      process_meter_update(meter_id, tick_count, config)
    end
  rescue MqttConnectionService::ConnectionError => e
    Rails.logger.error "MQTT connection error: #{e.message}"
    # Could implement retry logic here
  rescue StandardError => e
    Rails.logger.error "Unexpected error in MQTT listener: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end

  private

  def process_meter_update(meter_id, tick_count, config)
    Rails.logger.debug "Meter #{meter_id} update: #{tick_count} ticks"

    # Find the flow meter associated with this MQTT meter ID
    flow_meter = FlowMeter.find_by(meter_name: "Meter #{meter_id}") # Adjust based on your naming convention

    unless flow_meter
      Rails.logger.warn "No flow meter found for meter ID #{meter_id}"
      return
    end

    # Calculate volume from ticks
    # Typical flow meter: ~2200 ticks per liter
    # Adjust ticks_per_ml based on your specific flow meter calibration
    ticks_per_ml = flow_meter.ticks_per_ml || 2.2 # Default: 2.2 ticks per mL (2200 per liter)

    # Check if this is a new pour (tick count increased significantly)
    last_tick_count = Rails.cache.read("meter_#{meter_id}_ticks") || 0
    tick_difference = tick_count - last_tick_count

    if tick_difference > 10 # Minimum threshold to consider it a pour
      # Find or create a drink record
      create_drink(flow_meter, tick_difference, ticks_per_ml)
    end

    # Store current tick count
    Rails.cache.write("meter_#{meter_id}_ticks", tick_count)
  end

  def create_drink(flow_meter, tick_count, ticks_per_ml)
    # Find the tap associated with this flow meter
    tap = flow_meter.tap
    return unless tap&.current_keg

    volume_ml = tick_count / ticks_per_ml

    # Create drink record
    drink = Drink.create!(
      keg: tap.current_keg,
      volume_ml: volume_ml,
      time: Time.current,
      status: "valid"
      # Add user_id if you have authentication token integration
      # Add drinking_session_id if you have session management
    )

    Rails.logger.info "Created drink: #{volume_ml.round(1)}ml from #{tap.name}"

    # Update keg served volume
    tap.current_keg.increment!(:served_volume_ml, volume_ml)

    # Could trigger events, notifications, etc. here
    SystemEvent.build_events_for_drink(drink)
  rescue StandardError => e
    Rails.logger.error "Error creating drink: #{e.message}"
  end
end
