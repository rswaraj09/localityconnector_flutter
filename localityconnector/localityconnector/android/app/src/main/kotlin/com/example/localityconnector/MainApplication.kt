package com.example.localityconnector

import androidx.multidex.MultiDexApplication
import com.google.firebase.FirebaseApp

class MainApplication : MultiDexApplication() {
    override fun onCreate() {
        super.onCreate()
        // Initialize Firebase
        FirebaseApp.initializeApp(this)
    }
} 