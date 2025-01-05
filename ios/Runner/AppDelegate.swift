import Cocoa
import FlutterMacOS
import UIKit
import Flutter
import CoreBluetooth

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, CBPeripheralManagerDelegate, CBCentralManagerDelegate {
    private var peripheralManager: CBPeripheralManager?
    private var centralManager: CBCentralManager?
    private var currentBeaconUUID: String?
    private var isScanning = false
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        // Initialize Method Channel
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "com.example.untitled4/lowlet_hightx", binaryMessenger: controller.binaryMessenger)

        channel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            
            switch call.method {
            case "startBeacon":
                self.currentBeaconUUID = call.arguments as? String
                self.startBeacon()
                result(true)
            case "stopBeacon":
                self.stopBeacon()
                result(nil)
            case "startScanninguuid":
                if let uuid = call.arguments as? String {
                    self.startScanning(uuid: uuid)
                }
                result(nil)
            case "stopScanning":
                self.stopScanning()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: - Beacon Advertising
    private func startBeacon() {
        guard let uuidString = currentBeaconUUID, let uuid = UUID(uuidString: uuidString) else {
            print("Invalid UUID")
            return
        }

        let beaconData: [String: Any] = [
            CBAdvertisementDataServiceUUIDsKey: [CBUUID(nsuuid: uuid)]
        ]
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        peripheralManager?.startAdvertising(beaconData)
        print("Beacon started with UUID: \(uuidString)")
    }

    private func stopBeacon() {
        peripheralManager?.stopAdvertising()
        print("Beacon advertising stopped")
    }

    // MARK: - Scanning for Beacons
    private func startScanning(uuid: String) {
        guard let targetUUID = UUID(uuidString: uuid) else {
            print("Invalid UUID for scanning")
            return
        }

        centralManager = CBCentralManager(delegate: self, queue: nil)
        let serviceUUIDs = [CBUUID(nsuuid: targetUUID)]
        centralManager?.scanForPeripherals(withServices: serviceUUIDs, options: nil)
        isScanning = true

        // Stop scanning after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if self.isScanning {
                self.stopScanning()
                print("Scanning stopped - target not found")
            }
        }
    }

    private func stopScanning() {
        centralManager?.stopScan()
        isScanning = false
        print("Stopped scanning")
    }

    // MARK: - CBPeripheralManagerDelegate
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state != .poweredOn {
            print("Bluetooth is not enabled on the device")
        }
    }

    // MARK: - CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("Bluetooth is not enabled on the device")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        print("Beacon found: \(peripheral.identifier)")
        stopScanning()
        // Send result back to Flutter
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(name: "com.example.untitled4/lowlet_hightx", binaryMessenger: controller.binaryMessenger)
        channel.invokeMethod("onBeaconFound", arguments: true)
    }
}
