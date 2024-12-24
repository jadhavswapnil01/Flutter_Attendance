package com.example.untitled4;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.net.wifi.WifiManager;
import android.net.wifi.ScanResult;
import android.content.Context;
import android.app.Activity;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothManager;
import android.bluetooth.le.AdvertiseCallback;
import android.bluetooth.le.AdvertiseData;
import android.bluetooth.le.AdvertiseSettings;
import android.bluetooth.le.BluetoothLeAdvertiser;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
// import android.bluetooth.le.ScanResult;
import android.bluetooth.le.ScanFilter;
import android.bluetooth.le.ScanSettings;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.ParcelUuid;
import android.widget.Toast;
import java.lang.reflect.Method; // For Method class
import android.net.wifi.WifiConfiguration;
import android.util.Log;
import android.content.pm.PackageManager;




import androidx.annotation.RequiresApi;

import java.util.ArrayList;
import java.util.List;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.untitled4/rssi";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("getRSSI")) {
                    String ssid = call.argument("ssid");
                    try {
                        int rssi = getRSSI(ssid);
                        if (rssi != Integer.MIN_VALUE) {
                            result.success(rssi);
                        } else {
                            result.error("UNAVAILABLE", "RSSI not available", null);
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                        result.error("ERROR", "Error fetching RSSI: " + e.getMessage(), null);
                    }
                }else  if (call.method.equals("getHotspotSSID")) {
                    try {
                        String hotspotSSID = getHotspotSSID();
                        if (hotspotSSID != null) {
                            result.success(hotspotSSID);
                        } else {
                            result.error("UNAVAILABLE", "Hotspot SSID is not available or unsupported", null);
                        }
                    } catch (Exception e) {
                        Log.e("ERROR", "Error fetching Hotspot SSID: " + e.getMessage(), e);
                        result.error("ERROR", "Error fetching Hotspot SSID: " + e.getMessage(), null);
                    }
                } else {
                    result.notImplemented();
                }
                
            });
    }



    private int getRSSI(String ssid) {
        WifiManager wifiManager = (WifiManager) getApplicationContext().getSystemService(Context.WIFI_SERVICE);
    
        if (wifiManager == null) {
            Log.e("ERROR", "WifiManager is not available.");
            return Integer.MIN_VALUE;
        }
    
        // Check if Wi-Fi is enabled
        int wifiState = wifiManager.getWifiState();
        if (wifiState != WifiManager.WIFI_STATE_ENABLED) {
            Log.e("ERROR", "Wi-Fi is not enabled. Current state: " + wifiState);
            return Integer.MIN_VALUE;
        }
    
        // Check permissions
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) { // Android 13+
            if (checkSelfPermission(android.Manifest.permission.NEARBY_WIFI_DEVICES) != PackageManager.PERMISSION_GRANTED) {
                Log.e("ERROR", "NEARBY_WIFI_DEVICES permission not granted.");
                return Integer.MIN_VALUE;
            }
        } else {
            if (checkSelfPermission(android.Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
                Log.e("ERROR", "ACCESS_FINE_LOCATION permission not granted.");
                return Integer.MIN_VALUE;
            }
        }
    
        // Start Wi-Fi scan and fetch results
        wifiManager.startScan();
        List<ScanResult> scanResults = wifiManager.getScanResults();
        for (ScanResult scanResult : scanResults) {
            String currentSSID;
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) { // Android 13+
                currentSSID = scanResult.getWifiSsid() != null ? scanResult.getWifiSsid().toString() : null;
                if (currentSSID != null && currentSSID.startsWith("\"") && currentSSID.endsWith("\"")) {
                    currentSSID = currentSSID.substring(1, currentSSID.length() - 1); // Remove quotes
                }
            } else {
                currentSSID = scanResult.SSID;
            }
    
            Log.d("DEBUG", "Checking SSID: " + currentSSID);
            if (currentSSID != null && currentSSID.equals(ssid)) {
                return scanResult.level; // Return the RSSI value
            }
        }
    
        Log.e("ERROR", "SSID not found: " + ssid);
        return Integer.MIN_VALUE; // RSSI not available
    }
    
    

    private String getHotspotSSID() {
        WifiManager wifiManager = (WifiManager) getApplicationContext().getSystemService(Context.WIFI_SERVICE);
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) { // Android 9 and below
            try {
                Method method = wifiManager.getClass().getDeclaredMethod("getWifiApConfiguration");
                method.setAccessible(true);
                WifiConfiguration config = (WifiConfiguration) method.invoke(wifiManager);
                if (config != null) {
                    return config.SSID;
                }
            } catch (Exception e) {
                e.printStackTrace();
                Log.e("ERROR", "Error fetching Hotspot SSID: " + e.getMessage());
            }
        } else {
            Log.e("ERROR", "Fetching Hotspot SSID is not supported on Android 10+");
        }
        return null;
    }
    
    
}
