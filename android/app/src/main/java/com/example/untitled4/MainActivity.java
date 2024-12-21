package com.example.untitled4;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.net.wifi.WifiManager;
import android.net.wifi.ScanResult;
import android.content.Context;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.untitled4/rssi";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("getRSSI")) {
                    String ssid = call.argument("ssid");
                    int rssi = getRSSI(ssid);
                    if (rssi != Integer.MIN_VALUE) {
                        result.success(rssi);
                    } else {
                        result.error("UNAVAILABLE", "RSSI not available", null);
                    }
                } else {
                    result.notImplemented();
                }
            });
    }

    private int getRSSI(String ssid) {
        WifiManager wifiManager = (WifiManager) getApplicationContext().getSystemService(Context.WIFI_SERVICE);
        if (wifiManager != null) {
            for (ScanResult scanResult : wifiManager.getScanResults()) {
                if (scanResult.getWifiSsid() != null && scanResult.getWifiSsid().toString().equals(ssid)) {
                    return scanResult.level;
                }
            }
        }
        return Integer.MIN_VALUE;
    }
}
