import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let audio_method_channel = FlutterMethodChannel(name: "audio_method_channel", binaryMessenger: controller.binaryMessenger)
    audio_method_channel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "startPlayback" {
        self.startPlayback(result: result)
      } else if call.method == "stopPlayback" {
        self.stopPlayback(result: result)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func startPlayback(result: FlutterResult) {
    
    result("started")
  }
  
  private func stopPlayback(result: FlutterResult) {
    result("stopped")
  }
}
