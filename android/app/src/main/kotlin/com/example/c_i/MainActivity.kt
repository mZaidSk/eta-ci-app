package com.example.c_i

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.view.WindowManager

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Allow screenshots by clearing the FLAG_SECURE flag BEFORE super.onCreate
        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        super.onCreate(savedInstanceState)
    }

    override fun onResume() {
        super.onResume()
        // Ensure screenshots are allowed when app resumes
        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
}
