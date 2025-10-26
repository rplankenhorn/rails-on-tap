package com.railsontap

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.railsontap.api.ApiClient
import com.railsontap.api.TapResponse
import com.railsontap.api.DrinkResponse
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.text.SimpleDateFormat
import java.util.*

class TapListActivity : AppCompatActivity() {
    private lateinit var recyclerView: RecyclerView
    private lateinit var adapter: TapListAdapter
    private lateinit var recentPoursRecyclerView: RecyclerView
    private lateinit var recentPoursAdapter: RecentPoursAdapter
    
    companion object {
        private const val CAMERA_PERMISSION_CODE = 100
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_tap_list)
        
        setupRecyclerView()
        setupRecentPoursRecyclerView()
        checkCameraPermission()
        loadTaps()
        loadRecentPours()
    }
    
    private fun setupRecyclerView() {
        recyclerView = findViewById(R.id.tap_recycler_view)
        recyclerView.layoutManager = androidx.recyclerview.widget.GridLayoutManager(this, 2)
        adapter = TapListAdapter { tap ->
            onTapSelected(tap)
        }
        recyclerView.adapter = adapter
    }
    
    private fun setupRecentPoursRecyclerView() {
        recentPoursRecyclerView = findViewById(R.id.recent_pours_recycler_view)
        recentPoursRecyclerView.layoutManager = LinearLayoutManager(this)
        recentPoursAdapter = RecentPoursAdapter()
        recentPoursRecyclerView.adapter = recentPoursAdapter
    }
    
    private fun checkCameraPermission() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)
            != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.CAMERA),
                CAMERA_PERMISSION_CODE
            )
        }
    }
    
    private fun loadTaps() {
        val call = ApiClient.apiService.getTaps(ApiClient.getApiKey())
        
        call.enqueue(object : Callback<List<TapResponse>> {
            override fun onResponse(
                call: Call<List<TapResponse>>,
                response: Response<List<TapResponse>>
            ) {
                if (response.isSuccessful) {
                    val tapResponses = response.body() ?: emptyList()
                    val taps = tapResponses.mapNotNull { tapResponse ->
                        val keg = tapResponse.keg
                        val beverage = keg?.beverage
                        
                        // Only show taps with active kegs
                        if (keg != null && keg.status == "on_tap" && beverage != null) {
                            val percentFull = calculatePercentFull(keg.initialVolume, keg.finalVolume)
                            val beverageName = beverage.name
                            val producerName = beverage.beverageProducer?.name ?: "Unknown"
                            
                            Tap(
                                id = tapResponse.id,
                                name = tapResponse.name,
                                beverageType = beverageName,
                                producer = producerName,
                                percentFull = percentFull
                            )
                        } else {
                            null
                        }
                    }
                    adapter.submitList(taps)
                } else {
                    Log.e("TapListActivity", "Failed to load taps: ${response.code()}")
                    Toast.makeText(
                        this@TapListActivity,
                        "Failed to load taps: ${response.code()}",
                        Toast.LENGTH_SHORT
                    ).show()
                }
            }
            
            override fun onFailure(call: Call<List<TapResponse>>, t: Throwable) {
                Log.e("TapListActivity", "Error loading taps", t)
                Toast.makeText(
                    this@TapListActivity,
                    "Error: ${t.message}",
                    Toast.LENGTH_SHORT
                ).show()
            }
        })
    }
    
    private fun calculatePercentFull(initialVolume: Float?, finalVolume: Float?): Float {
        if (initialVolume == null || initialVolume == 0f) return 0f
        val currentVolume = (initialVolume ?: 0f) - (finalVolume ?: 0f)
        return ((currentVolume / initialVolume) * 100).coerceIn(0f, 100f)
    }
    
    private fun loadRecentPours() {
        val call = ApiClient.apiService.getDrinks(ApiClient.getApiKey(), limit = 20)
        
        call.enqueue(object : Callback<List<DrinkResponse>> {
            override fun onResponse(
                call: Call<List<DrinkResponse>>,
                response: Response<List<DrinkResponse>>
            ) {
                if (response.isSuccessful) {
                    val drinkResponses = response.body() ?: emptyList()
                    val pours = drinkResponses.map { drink ->
                        val userName = drink.user.displayName ?: drink.user.username
                        val beverageName = drink.keg.beverage?.name ?: "Unknown"
                        val volumeOz = (drink.volumeMl * 0.033814).toInt()
                        val timeAgo = formatTimeAgo(drink.time)
                        
                        // TODO: Get actual photo URL from pictures API
                        val photoUrl: String? = null
                        
                        Pour(
                            id = drink.id,
                            userName = userName,
                            beverageName = beverageName,
                            volumeOz = volumeOz,
                            timeAgo = timeAgo,
                            photoUrl = photoUrl
                        )
                    }
                    recentPoursAdapter.submitList(pours)
                } else {
                    Log.e("TapListActivity", "Failed to load drinks: ${response.code()}")
                }
            }
            
            override fun onFailure(call: Call<List<DrinkResponse>>, t: Throwable) {
                Log.e("TapListActivity", "Error loading drinks", t)
            }
        })
    }
    
    private fun formatTimeAgo(isoTime: String): String {
        return try {
            val format = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", Locale.US)
            format.timeZone = TimeZone.getTimeZone("UTC")
            val date = format.parse(isoTime) ?: return "Unknown"
            
            val now = System.currentTimeMillis()
            val diff = now - date.time
            val seconds = diff / 1000
            val minutes = seconds / 60
            val hours = minutes / 60
            val days = hours / 24
            
            when {
                seconds < 60 -> "${seconds}s ago"
                minutes < 60 -> "${minutes}m ago"
                hours < 24 -> "${hours}h ago"
                else -> "${days}d ago"
            }
        } catch (e: Exception) {
            Log.e("TapListActivity", "Error parsing time", e)
            "Unknown"
        }
    }
    
    private fun onTapSelected(tap: Tap) {
        // TODO: Open camera for pour recording
        Toast.makeText(this, "Recording pour from ${tap.name}", Toast.LENGTH_SHORT).show()
    }
    
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == CAMERA_PERMISSION_CODE) {
            if (grantResults.isEmpty() || grantResults[0] != PackageManager.PERMISSION_GRANTED) {
                Toast.makeText(this, "Camera permission required for pour recording", Toast.LENGTH_LONG).show()
            }
        }
    }
}

data class Tap(
    val id: Int,
    val name: String,
    val beverageType: String,
    val producer: String,
    val percentFull: Float
)
