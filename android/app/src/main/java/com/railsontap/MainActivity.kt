package com.railsontap

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Launch the tap list activity
        val intent = Intent(this, TapListActivity::class.java)
        startActivity(intent)
        finish()
    }
}
