package com.railsontap.api

import com.railsontap.BuildConfig
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit

object ApiClient {
    // Configuration loaded from local.properties
    // Use 10.0.2.2 for Android emulator to access localhost on the host machine
    // Change BASE_URL in local.properties to your actual IP address if testing on a real device
    private val BASE_URL = BuildConfig.RAILS_API_BASE_URL
    
    // API key loaded from local.properties - DO NOT hardcode!
    private val API_KEY = BuildConfig.RAILS_API_KEY

    private val loggingInterceptor = HttpLoggingInterceptor().apply {
        level = HttpLoggingInterceptor.Level.BODY
    }

    private val okHttpClient = OkHttpClient.Builder()
        .addInterceptor(loggingInterceptor)
        .connectTimeout(30, TimeUnit.SECONDS)
        .readTimeout(30, TimeUnit.SECONDS)
        .build()

    private val retrofit = Retrofit.Builder()
        .baseUrl(BASE_URL)
        .client(okHttpClient)
        .addConverterFactory(GsonConverterFactory.create())
        .build()

    val apiService: RailsApiService = retrofit.create(RailsApiService::class.java)
    
    fun getApiKey(): String = API_KEY
}
