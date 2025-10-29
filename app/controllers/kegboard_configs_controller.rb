class KegboardConfigsController < ApplicationController
  before_action :set_kegboard_config, only: [ :show, :edit, :update, :destroy, :test_connection, :initialize_hardware ]

  def index
    @kegboard_configs = KegboardConfig.all.order(created_at: :desc)
  end

  def show
  end

  def new
    @kegboard_config = KegboardConfig.new(
      config_type: "mqtt",
      mqtt_port: 1883,
      mqtt_topic_prefix: "kegbot"
    )
  end

  def create
    @kegboard_config = KegboardConfig.new(kegboard_config_params)

    if @kegboard_config.save
      redirect_to kegboard_configs_path, notice: "Kegboard configuration was successfully created."
    else
      # Log validation errors for debugging
      Rails.logger.error "KegboardConfig validation failed: #{@kegboard_config.errors.full_messages.join(', ')}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @kegboard_config.update(kegboard_config_params)
      redirect_to kegboard_configs_path, notice: "Kegboard configuration was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @kegboard_config.destroy
    redirect_to kegboard_configs_path, notice: "Kegboard configuration was successfully deleted."
  end

  def test_connection
    service = MqttConnectionService.new(@kegboard_config)
    result = service.test_connection

    if result[:success]
      # Auto-initialize hardware if connection successful
      initialize_hardware_result = initialize_hardware_from_config

      flash[:notice] = "✅ #{result[:message]}<br>" \
                       "Broker: #{result[:broker]}:#{result[:port]}<br>" \
                       "Test Topic: #{result[:test_topic]}<br>" \
                       "#{initialize_hardware_result[:message]}"
    else
      flash[:alert] = "❌ Connection failed: #{result[:error]}"
    end

    redirect_to kegboard_configs_path
  end

  def initialize_hardware
    result = initialize_hardware_from_config

    if result[:success]
      flash[:notice] = result[:message]
    else
      flash[:alert] = result[:error]
    end

    redirect_to kegboard_configs_path
  end

  private

  def set_kegboard_config
    @kegboard_config = KegboardConfig.find(params[:id])
  end

  def kegboard_config_params
    params.require(:kegboard_config).permit(
      :name,
      :config_type,
      :mqtt_broker,
      :mqtt_port,
      :mqtt_username,
      :mqtt_password,
      :mqtt_topic_prefix,
      :enabled
    )
  end

  def initialize_hardware_from_config
    # Create a hardware controller based on the kegboard config name
    controller_name = @kegboard_config.name.presence || "kegboard"
    controller = HardwareController.find_or_create_by(name: controller_name) do |c|
      c.controller_model_name = "MQTT Kegboard"
    end

    # Create default flow meters (0-2 for 3 flow meter setup)
    flow_meter_count = 0
    (0..2).each do |meter_num|
      meter = FlowMeter.find_or_create_by(
        controller: controller,
        port_name: "flow#{meter_num}"
      ) do |m|
        m.ticks_per_ml = FlowMeter::DEFAULT_TICKS_PER_ML
      end
      flow_meter_count += 1 if meter.persisted?
    end

    {
      success: true,
      message: "Hardware initialized: 1 controller, #{flow_meter_count} flow meters available"
    }
  rescue StandardError => e
    Rails.logger.error "Failed to initialize hardware: #{e.message}"
    {
      success: false,
      error: "Failed to initialize hardware: #{e.message}"
    }
  end
end
