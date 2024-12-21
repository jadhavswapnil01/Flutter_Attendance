import Flutter
import UIKit
import SystemConfiguration.CaptiveNetwork

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Define the method channel
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "com.example.wifi/rssi", binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler { [weak self] (call, result) in
      guard call.method == "getRSSI" else {
        result(FlutterMethodNotImplemented)
        return
      }

      if let arguments = call.arguments as? [String: Any],
         let ssid = arguments["ssid"] as? String {
        let rssi = self?.getRSSI(forSSID: ssid)
        result(rssi ?? -100) // Return -100 if RSSI is not available
      } else {
        result(FlutterError(code: "INVALID_ARGUMENT", message: "SSID not provided", details: nil))
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func getRSSI(forSSID ssid: String) -> Int? {
    // Get the list of supported Wi-Fi interfaces
    guard let interfaces = CNCopySupportedInterfaces() as? [String] else { return nil }
    for interface in interfaces {
      // Get network info for the current interface
      if let info = CNCopyCurrentNetworkInfo(interface as CFString) as NSDictionary? {
        // Check if the SSID matches
        if let currentSSID = info[kCNNetworkInfoKeySSID as String] as? String, currentSSID == ssid {
          // Return the RSSI value
          return info[kCNNetworkInfoKeyRSSI as String] as? Int
        }
      }
    }
    return nil
  }
}
