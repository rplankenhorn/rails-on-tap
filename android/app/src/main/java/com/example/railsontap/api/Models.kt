package com.railsontap.api

import com.google.gson.annotations.SerializedName

// API Response Models

data class TapResponse(
    val id: Int,
    val name: String,
    val position: Int,
    val keg: KegResponse?,
    @SerializedName("flow_meter") val flowMeter: FlowMeterResponse?,
    @SerializedName("flow_toggle") val flowToggle: FlowToggleResponse?,
    @SerializedName("hardware_controller") val hardwareController: HardwareControllerResponse?,
    @SerializedName("updated_at") val updatedAt: String
)

data class KegResponse(
    val id: Int,
    val name: String?,
    @SerializedName("beverage_id") val beverageId: Int?,
    val status: String,
    @SerializedName("started_at") val startedAt: String?,
    @SerializedName("ended_at") val endedAt: String?,
    @SerializedName("initial_volume") val initialVolume: Float?,
    @SerializedName("final_volume") val finalVolume: Float?,
    val beverage: BeverageResponse?
)

data class BeverageResponse(
    val id: Int,
    val name: String,
    val style: String?,
    @SerializedName("beverage_type") val beverageType: String,
    @SerializedName("abv_percent") val abvPercent: Float?,
    @SerializedName("beverage_producer") val beverageProducer: BeverageProducerResponse?
)

data class BeverageProducerResponse(
    val id: Int,
    val name: String,
    val country: String?,
    val origin_state: String?,
    val origin_city: String?
)

data class FlowMeterResponse(
    val id: Int,
    val name: String,
    val port: String
)

data class FlowToggleResponse(
    val id: Int,
    val name: String,
    val port: String
)

data class HardwareControllerResponse(
    val id: Int,
    val name: String,
    @SerializedName("device_type") val deviceType: String
)

data class DrinkResponse(
    val id: Int,
    val ticks: Int,
    @SerializedName("volume_ml") val volumeMl: Float,
    val time: String,
    val duration: Int,
    val shout: String?,
    val user: UserResponse,
    val keg: KegResponse,
    @SerializedName("drinking_session") val drinkingSession: DrinkingSessionResponse?
)

data class UserResponse(
    val id: Int,
    val username: String,
    @SerializedName("display_name") val displayName: String?,
    val email: String?
)

data class DrinkingSessionResponse(
    val id: Int,
    @SerializedName("start_time") val startTime: String,
    @SerializedName("end_time") val endTime: String?
)

// UI Models (simplified for display)

data class Tap(
    val id: Int,
    val name: String,
    val beverageName: String,
    val producerName: String,
    val percentFull: Int
)

data class Pour(
    val id: Int,
    val userName: String,
    val beverageName: String,
    val volumeOz: String,
    val timeAgo: String,
    val photoUrl: String?
)
