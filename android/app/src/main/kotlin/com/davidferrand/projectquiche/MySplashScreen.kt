package com.davidferrand.projectquiche

import android.annotation.SuppressLint
import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import io.flutter.embedding.android.SplashScreen

class MySplashScreen : SplashScreen {
    @SuppressLint("InflateParams")
    override fun createSplashView(context: Context, savedInstanceState: Bundle?): View? {
        return LayoutInflater.from(context).inflate(R.layout.splash_screen, null)
    }

    override fun transitionToFlutter(onTransitionComplete: Runnable) {
        onTransitionComplete.run()
    }

}
