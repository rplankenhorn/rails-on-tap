package com.railsontap.api

import retrofit2.Call
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.Query

interface RailsApiService {
    @GET("api/v1/taps")
    fun getTaps(
        @Header("X-API-Key") apiKey: String
    ): Call<List<TapResponse>>

    @GET("api/v1/drinks")
    fun getDrinks(
        @Header("X-API-Key") apiKey: String,
        @Query("limit") limit: Int = 20
    ): Call<List<DrinkResponse>>
}
