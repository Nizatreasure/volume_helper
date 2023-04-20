package com.niza.volume_helper;

import io.flutter.embedding.android.FlutterActivity;

import android.media.AudioManager;
import android.util.Log;
import android.util.TypedValue;
import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.content.res.Resources;
import android.view.KeyEvent;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "niza.volume_controller";
    Resources resources;
    private boolean listenToVolumeEvent = false;
    AudioManager manager;

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        resources = getApplicationContext().getResources();
        manager = (AudioManager) getSystemService(ContextWrapper.AUDIO_SERVICE);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("getPx")) {
                        result.success(dpToPx(call.argument("dp")));
                    } else if (call.method.equals("chaneListenToVolume")) {
                        listenToVolumeEvent = (boolean) call.argument("listenToVolume");
                        result.success(true);
                    } else {
                        result.notImplemented();
                    }
                });
    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        Log.d("closest", "onKeyDown");
        if (listenToVolumeEvent) {
            switch (event.getKeyCode()) {
                case KeyEvent.KEYCODE_VOLUME_UP:
                    manager.adjustStreamVolume(AudioManager.STREAM_MUSIC,
                            AudioManager.ADJUST_RAISE, AudioManager.FLAG_REMOVE_SOUND_AND_VIBRATE);
                    return true;
                case KeyEvent.KEYCODE_VOLUME_DOWN:
                    manager.adjustStreamVolume(AudioManager.STREAM_MUSIC,
                            AudioManager.ADJUST_LOWER, AudioManager.FLAG_REMOVE_SOUND_AND_VIBRATE);
                    return true;

                default:
                    return super.onKeyDown(keyCode, event);
            }
        } else {
            return super.onKeyDown(keyCode, event);

        }
    }

    private int dpToPx(int dp) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP,
                Float.parseFloat(dp + ""), resources.getDisplayMetrics());
    }

}
