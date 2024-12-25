package com.example.untitled4;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.net.wifi.WifiManager;
// import android.net.wifi.ScanResult;
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
import android.bluetooth.le.ScanResult;
import android.bluetooth.le.ScanFilter;
import android.bluetooth.le.ScanSettings;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.ParcelUuid;
import android.widget.Toast;
import android.os.Looper;
import java.lang.reflect.Method; // For Method class
import android.net.wifi.WifiConfiguration;
import android.util.Log;
import android.content.pm.PackageManager;
import android.content.Intent;




import androidx.annotation.RequiresApi;

import java.util.ArrayList;
import java.util.List;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.untitled4/rssi";
    private BluetoothAdapter bluetoothAdapter;
    private BluetoothLeAdvertiser advertiser;
    private BluetoothLeScanner scanner;
    private static final int REQUEST_ENABLE_BT = 1;


    private final String BEACON_UUID = "12345678-1234-1234-1234-123456789abc"; // Your beacon UUID

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Initialize Bluetooth Adapter
        BluetoothManager bluetoothManager = (BluetoothManager) getSystemService(BLUETOOTH_SERVICE);
        bluetoothAdapter = bluetoothManager.getAdapter();

        

        // Initialize advertiser and scanner
        advertiser = bluetoothAdapter.getBluetoothLeAdvertiser();
        scanner = bluetoothAdapter.getBluetoothLeScanner();

    }
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
                    } else if (call.method.equals("startBeacon")) {
                        startBeacon();
                        result.success(null);
                    } else if (call.method.equals("stopBeacon")) {
                        stopBeacon();
                        result.success(null);
                    } else if (call.method.equals("startScanning")) {
                        startScanning();
                        result.success(null);
                    } else if (call.method.equals("stopScanning")) {
                        stopScanning();
                        result.success(null);
                    } else {
                        result.notImplemented();
                    }
                
            });
    }
    

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public void startBeacon() {
        if (bluetoothAdapter == null || !bluetoothAdapter.isEnabled()) {
            Toast.makeText(this, "Bluetooth is not enabled please enable it for online attendance", Toast.LENGTH_LONG).show();
            Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
           
        }
        
        if (advertiser == null) {
            Toast.makeText(this, "BLE Advertising not supported", Toast.LENGTH_LONG).show();
            return;
        }

         // Advertise settings
         AdvertiseSettings settings = new AdvertiseSettings.Builder()
         .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
         .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_HIGH)
         .setConnectable(false)
         .build();

        ParcelUuid parcelUuid = ParcelUuid.fromString(BEACON_UUID); // Use your UUID for the beacon

        // Advertise data
        AdvertiseData data = new AdvertiseData.Builder()
                .addServiceUuid(parcelUuid)
                .build();

        advertiser.startAdvertising(settings, data, advertiseCallback);
        }
        
        @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
        public void startScanning() {
            if (bluetoothAdapter == null || !bluetoothAdapter.isEnabled()) {
                Toast.makeText(this, "Bluetooth is not enabled please enable it for online attendance", Toast.LENGTH_LONG).show();
                Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
                startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
               
            }
            if (scanner == null) {
                Toast.makeText(this, "BLE Scanning not supported", Toast.LENGTH_LONG).show();
                return;
            }
    
            scanner.startScan(scanCallback);
    
            // Stop scanning after 10 seconds
            new Handler(Looper.getMainLooper()).postDelayed(() -> scanner.stopScan(scanCallback), 10000);
    
        }

        private void stopBeacon() {
            if (advertiser != null) {
                advertiser.stopAdvertising(advertiseCallback);
                Toast.makeText(this, "Beacon stopped", Toast.LENGTH_SHORT).show();
            }
        }
    
        private void stopScanning() {
            if (scanner != null) {
                scanner.stopScan(scanCallback);
                Toast.makeText(this, "Scanning stopped", Toast.LENGTH_SHORT).show();
            }
        }
    
        private final AdvertiseCallback advertiseCallback = new AdvertiseCallback() {
            @Override
            public void onStartSuccess(AdvertiseSettings settingsInEffect) {
                super.onStartSuccess(settingsInEffect);
                Toast.makeText(MainActivity.this, "Beacon started successfully", Toast.LENGTH_SHORT).show();
            }
    
            @Override
            public void onStartFailure(int errorCode) {
                super.onStartFailure(errorCode);
                Toast.makeText(MainActivity.this, "Beacon failed to start: " + errorCode, Toast.LENGTH_SHORT).show();
            }
        };

        private final ScanCallback scanCallback = new ScanCallback() {
            @Override
            public void onScanResult(int callbackType, ScanResult result) {
                super.onScanResult(callbackType, result);
                BluetoothDevice device = result.getDevice();
                if (result.getScanRecord() != null &&
                        result.getScanRecord().getServiceUuids() != null &&
                        result.getScanRecord().getServiceUuids().contains(ParcelUuid.fromString(BEACON_UUID))) {
                    Toast.makeText(MainActivity.this, "Beacon found: " + device.getAddress(), Toast.LENGTH_SHORT).show();
    
                    // Calculate distance based on RSSI
                    int rssi = result.getRssi();
                    double distance = calculateDistance(rssi);
                    Toast.makeText(MainActivity.this, "Distance: " + distance + " meters", Toast.LENGTH_SHORT).show();
                }
            }
        };

        private double calculateDistance(int rssi) {
            int txPower = -59; // Assumed TX power at 1m distance
            return Math.pow(10d, ((double) txPower - rssi) / (10 * 2));
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
        List<android.net.wifi.ScanResult> scanResults = wifiManager.getScanResults();
        for (android.net.wifi.ScanResult scanResult : scanResults) {
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
