package com.https1121.overdrive.companion;

import android.app.Application;
import com.google.android.material.color.DynamicColors;

public class App extends Application {
    @Override public void onCreate() {
        super.onCreate();
        // Material You: colors from the user's wallpaper on Android 12+.
        DynamicColors.applyToActivitiesIfAvailable(this);
    }
}
