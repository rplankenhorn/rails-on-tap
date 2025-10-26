package com.railsontap

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import dev.hotwire.android.nav.HotwireNavRule
import dev.hotwire.android.navigation.HotwireActivity
import java.net.URL

class MainActivity : HotwireActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override val startLocation: URL
        get() = URL("http://localhost:3000")

    override fun onCreateNavRules(): List<HotwireNavRule> {
        return listOf(
            HotwireNavRule(
                "http://localhost:3000/**",
                destinationIdentifier = "web"
            )
        )
    }
}
