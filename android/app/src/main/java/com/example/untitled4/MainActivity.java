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
import android.provider.Settings;




import androidx.annotation.RequiresApi;

import java.util.ArrayList;
import java.util.List;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.untitled4/rssi";
    private BluetoothAdapter bluetoothAdapter;
    private BluetoothLeAdvertiser advertiser;
    private BluetoothLeScanner scanner;
    private static final int REQUEST_ENABLE_BT = 1;
    private String currentBeaconUUID = null;


    // private final String BEACON_UUID = "12345678-1234-1234-1234-123456789abc"; // Your beacon UUID

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // Initialize Bluetooth Adapter
        BluetoothManager bluetoothManager = (BluetoothManager) getSystemService(BLUETOOTH_SERVICE);
        bluetoothAdapter = bluetoothManager.getAdapter();

        if (bluetoothAdapter == null || !bluetoothAdapter.isEnabled()) {
            Toast.makeText(this, "Bluetooth is not enabled", Toast.LENGTH_LONG).show();
            
        }

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
                        currentBeaconUUID = call.argument("uuid");
                        // startBeacon();
                        result.success(startBeacon());
                    } else if (call.method.equals("stopBeacon")) {
                        
                        stopBeacon();
                        result.success(null);
                    } else if (call.method.equals("startScanninguuid")) {
                        String uuid = call.argument("uuid");
                        startScanninguuid(uuid); // Pass the maxRetries argument
    
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
    public boolean startBeacon() {
        if (!bluetoothAdapter.isEnabled()) {
            requestBluetoothEnable();
            Log.e("BeaconError", "Bluetooth is not enabled.");
            return false;
        }
    
        BluetoothManager bluetoothManager = (BluetoothManager) getSystemService(BLUETOOTH_SERVICE);
        bluetoothAdapter = bluetoothManager.getAdapter();
        advertiser = bluetoothAdapter.getBluetoothLeAdvertiser();
    
        if (advertiser == null) {
            Log.e("BeaconError", "BluetoothLeAdvertiser is null. Check BLE support.");
            return false;
        }
    
        if (currentBeaconUUID == null || currentBeaconUUID.isEmpty()) {
            Log.e("BeaconError", "Invalid UUID: " + currentBeaconUUID);
            return false;
        }
    
        AdvertiseSettings settings = new AdvertiseSettings.Builder()
                .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_LOW_LATENCY)
                .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_HIGH)
                .setConnectable(false)
                .build();
    
        ParcelUuid parcelUuid = ParcelUuid.fromString(currentBeaconUUID);
    
        AdvertiseData data = new AdvertiseData.Builder()
                .addServiceUuid(parcelUuid)
                .build();
    
        try {
            advertiser.startAdvertising(settings, data, advertiseCallback);
            Log.d("BeaconStatus", "Beacon advertising started successfully.");
            return true;
        } catch (Exception e) {
            Log.e("BeaconError", "Error starting beacon: " + e.getMessage(), e);
            return false;
        }
    }
    

        // Add this method in your existing MainActivity class
@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
public void startScanninguuid(String uuid) {
    if (!bluetoothAdapter.isEnabled()) {
        requestBluetoothEnable();
        return;
    }

    BluetoothManager bluetoothManager = (BluetoothManager) getSystemService(BLUETOOTH_SERVICE);
    bluetoothAdapter = bluetoothManager.getAdapter();
    scanner = bluetoothAdapter.getBluetoothLeScanner();
    if (scanner == null) {
        Toast.makeText(this, "BLE Scanning not supported", Toast.LENGTH_LONG).show();
        return;
    }

    // Set UUID to scan for
    ParcelUuid targetUuid = ParcelUuid.fromString(uuid);
    ScanSettings scanSettings = new ScanSettings.Builder()
    .setScanMode(ScanSettings.SCAN_MODE_BALANCED)
    .build();

    // scanner.startScan(null, scanSettings, scanCallback);

    // Start scanning
    scanner.startScan(null, scanSettings,new ScanCallback() {
        @Override
        public void onScanResult(int callbackType, ScanResult result) {
            super.onScanResult(callbackType, result);

            if (result.getScanRecord() != null &&
                    result.getScanRecord().getServiceUuids() != null &&
                    result.getScanRecord().getServiceUuids().contains(targetUuid)) {
                scanner.stopScan(this); // Stop scanning immediately after finding the target
                Toast.makeText(MainActivity.this, "Beacon found: " + result.getDevice().getAddress(), Toast.LENGTH_SHORT).show();
                sendScanResultToFlutter(true);
            }
        }

        @Override
        public void onScanFailed(int errorCode) {
            super.onScanFailed(errorCode);
            Log.e("ScanError", "Scan failed with error: " + errorCode);
        }
    });

    // Stop scanning automatically after 10 seconds
    new Handler(Looper.getMainLooper()).postDelayed(() -> scanner.stopScan(scanCallback), 10000);
}

    
    // Helper to send scan results to Flutter
    private void sendScanResultToFlutter(boolean result) {
new MethodChannel(getFlutterEngine().getDartExecutor(), "com.example.untitled4/rssi")
        .invokeMethod("onBeaconFound", result);
}

        private void requestBluetoothEnable() {
            if (Build.VERSION.SDK_INT <= Build.VERSION_CODES.R) {
                // For Android 11 and below
                Intent enableBtIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
                startActivityForResult(enableBtIntent, REQUEST_ENABLE_BT);
            } else {
                // For Android 12 and above
                if (!bluetoothAdapter.isEnabled()) {
                    Intent intent = new Intent(Settings.ACTION_BLUETOOTH_SETTINGS);
                    startActivity(intent);
                    Toast.makeText(this, "Please enable Bluetooth manually for this feature to work.", Toast.LENGTH_LONG).show();
                }
            }
        }
    
        protected void onActivityResult(int requestCode, int resultCode, Intent data) {
            super.onActivityResult(requestCode, resultCode, data);
        
            if (requestCode == REQUEST_ENABLE_BT) {
                if (resultCode == Activity.RESULT_OK) {
                    Toast.makeText(this, "Bluetooth enabled successfully", Toast.LENGTH_SHORT).show();
                } else {
                    Toast.makeText(this, "Bluetooth enabling was denied", Toast.LENGTH_SHORT).show();
                }
            }
        }

        private void stopBeacon() {
            if (advertiser != null) {
                advertiser.stopAdvertising(advertiseCallback);
                Toast.makeText(this, "Beacon stopped", Toast.LENGTH_SHORT).show();
            }
        }
    
        private void stopScanning() {
            if (scanner != null && scanCallback != null) {
                scanner.stopScan(scanCallback); // Use the correct ScanCallback instance
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
                    result.getScanRecord().getServiceUuids().contains(ParcelUuid.fromString(currentBeaconUUID))) {
                    Toast.makeText(MainActivity.this, "Beacon found: " + device.getAddress(), Toast.LENGTH_SHORT).show();
        
                    // Calculate distance based on RSSI
                    int rssi = result.getRssi();
                    double distance = calculateDistance(rssi);
                    Toast.makeText(MainActivity.this, "Distance: " + distance + " meters", Toast.LENGTH_SHORT).show();
        
                    scanner.stopScan(this); // Stop scanning
                }
            }
        
            @Override
            public void onScanFailed(int errorCode) {
                super.onScanFailed(errorCode);
                Toast.makeText(MainActivity.this, "Scan failed with error: " + errorCode, Toast.LENGTH_SHORT).show();
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
