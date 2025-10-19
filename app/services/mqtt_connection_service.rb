class MqttConnectionService
  class ConnectionError < StandardError; end

  def initialize(kegboard_config)
    @config = kegboard_config
  end

  # Test the MQTT connection
  def test_connection
    return { success: false, error: "Configuration is not enabled" } unless @config.enabled
    return { success: false, error: "MQTT broker address is required" } if @config.mqtt_broker.blank?

    begin
      # Create connection with timeout
      client = create_client

      # Try to connect
      Timeout.timeout(5) do
        client.connect
      end

      # Test subscription to a meter topic
      test_topic = @config.meter_topic(0)
      client.subscribe(test_topic)

      # Disconnect
      client.disconnect

      {
        success: true,
        message: "Successfully connected to MQTT broker",
        broker: @config.mqtt_broker,
        port: @config.mqtt_port,
        test_topic: test_topic
      }
    rescue Timeout::Error
      {
        success: false,
        error: "Connection timeout - broker may be unreachable"
      }
    rescue Errno::ECONNREFUSED
      {
        success: false,
        error: "Connection refused - check broker address and port"
      }
    rescue Errno::EHOSTUNREACH, Errno::ENETUNREACH
      {
        success: false,
        error: "Host unreachable - check network connectivity"
      }
    rescue MQTT::ProtocolException => e
      {
        success: false,
        error: "MQTT protocol error: #{e.message}"
      }
    rescue MQTT::NotConnectedException
      {
        success: false,
        error: "Failed to establish MQTT connection"
      }
    rescue StandardError => e
      {
        success: false,
        error: "Unexpected error: #{e.message}",
        details: e.class.name
      }
    ensure
      client&.disconnect rescue nil
    end
  end

  # Subscribe to flow meter topics and process messages
  def subscribe_to_meters(&block)
    return unless @config.enabled

    client = create_client
    client.connect

    # Subscribe to all meter topics (0-9)
    topics = (0..9).map { |i| [ @config.meter_topic(i), 0 ] }
    client.subscribe(*topics)

    # Listen for messages
    client.get do |topic, message|
      meter_id = extract_meter_id(topic)
      next unless meter_id

      block.call(meter_id, message.to_i) if block_given?
    end
  rescue StandardError => e
    Rails.logger.error "MQTT subscription error: #{e.message}"
    raise ConnectionError, e.message
  ensure
    client&.disconnect rescue nil
  end

  private

  def create_client
    client_options = {
      host: @config.mqtt_broker,
      port: @config.mqtt_port || 1883,
      keep_alive: 30
    }

    # Add authentication if provided
    if @config.mqtt_username.present?
      client_options[:username] = @config.mqtt_username
      client_options[:password] = @config.mqtt_password if @config.mqtt_password.present?
    end

    MQTT::Client.new(client_options)
  end

  def extract_meter_id(topic)
    # Extract meter ID from topic like "kegbot/meter/0"
    match = topic.match(%r{/meter/(\d+)$})
    match ? match[1].to_i : nil
  end
end
