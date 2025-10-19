class KegboardConfigsController < ApplicationController
  before_action :set_kegboard_config, only: [ :show, :edit, :update, :destroy, :test_connection ]

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
      flash[:notice] = "✅ #{result[:message]}<br>" \
                       "Broker: #{result[:broker]}:#{result[:port]}<br>" \
                       "Test Topic: #{result[:test_topic]}"
    else
      flash[:alert] = "❌ Connection failed: #{result[:error]}"
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
end
