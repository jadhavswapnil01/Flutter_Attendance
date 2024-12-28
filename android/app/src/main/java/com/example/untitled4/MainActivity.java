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
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;
import androidx.annotation.RequiresApi;
import java.util.ArrayList;
import java.util.List;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL1 = "com.example.untitled4/lowlet_hightx";
    private static final String CHANNEL2 = "com.example.untitled4/ballet_hightx";
    private static final String CHANNEL3 = "com.example.untitled4/lowlet_medtx";
    private static final String CHANNEL4 = "com.example.untitled4/ballet_medtx";
    private static final String CHANNEL5 = "com.example.untitled4/lowlet_lowtx";
    private static final String CHANNEL6 = "com.example.untitled4/ballet_lowtx";
    private BluetoothAdapter bluetoothAdapter;
    private BluetoothLeAdvertiser advertiser;
    private BluetoothLeScanner scanner;
    private static final int REQUEST_ENABLE_BT = 1;
    private String currentBeaconUUID = null;
    


    

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

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL1)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("startBeacon")) {
                    currentBeaconUUID = call.argument("uuid");
                    // startBeacon();
                    result.success(startBeacon1());
                }else if (call.method.equals("startScanninguuid")) {
                    String uuid = call.argument("uuid");
                    startScanninguuid1(uuid); // Pass the maxRetries argument

                    result.success(null);
                }else if (call.method.equals("stopBeacon")) {
                        
                    stopBeacon1();
                    result.success(null);
                } else if (call.method.equals("stopScanning")) {
                    // stopScanning();
                    result.success(null);
                } else {
                    result.notImplemented();
                }
                
            });
            new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL2)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("startBeacon")) {
                    currentBeaconUUID = call.argument("uuid");
                    // startBeacon();
                    result.success(startBeacon2());
                }else if (call.method.equals("startScanninguuid")) {
                    String uuid = call.argument("uuid");
                    startScanninguuid2(uuid); // Pass the maxRetries argument

                    result.success(null);
                }else if (call.method.equals("stopBeacon")) {
                        
                    stopBeacon2();
                    result.success(null);
                } else if (call.method.equals("stopScanning")) {
                    // stopScanning();
                    result.success(null);
                } else {
                    result.notImplemented();
                }
                
            });
            new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL3)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("startBeacon")) {
                    currentBeaconUUID = call.argument("uuid");
                    // startBeacon();
                    result.success(startBeacon3());
                }else if (call.method.equals("startScanninguuid")) {
                    String uuid = call.argument("uuid");
                    startScanninguuid3(uuid); // Pass the maxRetries argument

                    result.success(null);
                }else if (call.method.equals("stopBeacon")) {
                        
                    stopBeacon3();
                    result.success(null);
                } else if (call.method.equals("stopScanning")) {
                    // stopScanning();
                    result.success(null);
                } else {
                    result.notImplemented();
                }
                
            });
            new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL4)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("startBeacon")) {
                    currentBeaconUUID = call.argument("uuid");
                    // startBeacon();
                    result.success(startBeacon4());
                }else if (call.method.equals("startScanninguuid")) {
                    String uuid = call.argument("uuid");
                    startScanninguuid4(uuid); // Pass the maxRetries argument

                    result.success(null);
                }else if (call.method.equals("stopBeacon")) {
                        
                    stopBeacon4();
                    result.success(null);
                } else if (call.method.equals("stopScanning")) {
                    // stopScanning();
                    result.success(null);
                } else {
                    result.notImplemented();
                }
                
            });
            new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL5)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("startBeacon")) {
                    currentBeaconUUID = call.argument("uuid");
                    // startBeacon();
                    result.success(startBeacon5());
                }else if (call.method.equals("startScanninguuid")) {
                    String uuid = call.argument("uuid");
                    startScanninguuid5(uuid); // Pass the maxRetries argument

                    result.success(null);
                }else if (call.method.equals("stopBeacon")) {
                        
                    stopBeacon5();
                    result.success(null);
                } else if (call.method.equals("stopScanning")) {
                    // stopScanning();
                    result.success(null);
                } else {
                    result.notImplemented();
                }
                
            });
            new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL6)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("startBeacon")) {
                    currentBeaconUUID = call.argument("uuid");
                    // startBeacon();
                    result.success(startBeacon6());
                }else if (call.method.equals("startScanninguuid")) {
                    String uuid = call.argument("uuid");
                    startScanninguuid6(uuid); // Pass the maxRetries argument

                    result.success(null);
                }else if (call.method.equals("stopBeacon")) {
                        
                    stopBeacon6();
                    result.success(null);
                } else if (call.method.equals("stopScanning")) {
                    // stopScanning();
                    result.success(null);
                } else {
                    result.notImplemented();
                }
                
            });
    }
    

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public boolean startBeacon1() {
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
    
    private ScanCallback scanCallback;

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public void startScanninguuid1(String uuid) {
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



@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public boolean startBeacon2() {
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
                .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_BALANCED)
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
    
    // private ScanCallback scanCallback;

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public void startScanninguuid2(String uuid) {
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
//         private void sendScanResultToFlutter(boolean result) {
//     new MethodChannel(getFlutterEngine().getDartExecutor(), "com.example.untitled4/rssi")
//             .invokeMethod("onBeaconFound", result);
// }




@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public boolean startBeacon3() {
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
                .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_MEDIUM)
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
    
    // private ScanCallback scanCallback;

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public void startScanninguuid3(String uuid) {
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
//         private void sendScanResultToFlutter(boolean result) {
//     new MethodChannel(getFlutterEngine().getDartExecutor(), "com.example.untitled4/rssi")
//             .invokeMethod("onBeaconFound", result);
// }




@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public boolean startBeacon4() {
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
                .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_BALANCED)
                .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_MEDIUM)
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
    
    // private ScanCallback scanCallback;

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public void startScanninguuid4(String uuid) {
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
//         private void sendScanResultToFlutter(boolean result) {
//     new MethodChannel(getFlutterEngine().getDartExecutor(), "com.example.untitled4/rssi")
//             .invokeMethod("onBeaconFound", result);
// }




@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public boolean startBeacon5() {
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
                .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_LOW)
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
    
    // private ScanCallback scanCallback;

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public void startScanninguuid5(String uuid) {
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
    
        
//         // Helper to send scan results to Flutter
//         private void sendScanResultToFlutter(boolean result) {
//     new MethodChannel(getFlutterEngine().getDartExecutor(), "com.example.untitled4/rssi")
//             .invokeMethod("onBeaconFound", result);
// }




@RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public boolean startBeacon6() {
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
                .setAdvertiseMode(AdvertiseSettings.ADVERTISE_MODE_BALANCED)
                .setTxPowerLevel(AdvertiseSettings.ADVERTISE_TX_POWER_LOW)
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
    
    // private ScanCallback scanCallback;

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public void startScanninguuid6(String uuid) {
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
    
        
//         // Helper to send scan results to Flutter
//         private void sendScanResultToFlutter(boolean result) {
//     new MethodChannel(getFlutterEngine().getDartExecutor(), "com.example.untitled4/rssi")
//             .invokeMethod("onBeaconFound", result);
// }


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

        private void stopBeacon1() {
            if (advertiser != null) {
                advertiser.stopAdvertising(advertiseCallback);
                Toast.makeText(this, "Beacon stopped", Toast.LENGTH_SHORT).show();
            }
        }
        private void stopBeacon2() {
            if (advertiser != null) {
                advertiser.stopAdvertising(advertiseCallback);
                Toast.makeText(this, "Beacon stopped", Toast.LENGTH_SHORT).show();
            }
        }
        private void stopBeacon3() {
            if (advertiser != null) {
                advertiser.stopAdvertising(advertiseCallback);
                Toast.makeText(this, "Beacon stopped", Toast.LENGTH_SHORT).show();
            }
        }
        private void stopBeacon4() {
            if (advertiser != null) {
                advertiser.stopAdvertising(advertiseCallback);
                Toast.makeText(this, "Beacon stopped", Toast.LENGTH_SHORT).show();
            }
        }
        private void stopBeacon5() {
            if (advertiser != null) {
                advertiser.stopAdvertising(advertiseCallback);
                Toast.makeText(this, "Beacon stopped", Toast.LENGTH_SHORT).show();
            }
        }
        private void stopBeacon6() {
            if (advertiser != null) {
                advertiser.stopAdvertising(advertiseCallback);
                Toast.makeText(this, "Beacon stopped", Toast.LENGTH_SHORT).show();
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
    
}
