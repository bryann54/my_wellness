import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let mapsChannel = FlutterMethodChannel(
      name: "com.legaldefender/maps",
      binaryMessenger: controller.binaryMessenger
    )

    mapsChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
      if call.method == "setApiKey" {
        if let args = call.arguments as? [String: Any],
           let apiKey = args["apiKey"] as? String {
          GMSServices.provideAPIKey(apiKey)
          result(nil)
        } else {
          result(FlutterError(code: "INVALID_ARGUMENTS",
                              message: "API key not provided",
                              details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}