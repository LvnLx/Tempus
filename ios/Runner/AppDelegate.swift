import UIKit
import Flutter
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private var methodChannel: FlutterMethodChannel!
  private var metronome: Metronome!
  
  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    
    methodChannel = FlutterMethodChannel(name: "audio_method_channel", binaryMessenger: controller.binaryMessenger)
    metronome = Metronome()
    
    methodChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      let arguments = call.arguments as? [String] ?? []
      
      switch call.method {
      case "postFlutterInit":
        self.postFlutterInit(result: result)
      case "initializeAudioBuffer":
        self.metronome.initializeAudioBuffer()
        result("Initialized audio buffer")
      case "startPlayback":
        self.metronome.startPlayback()
        result("Started playback")
      case "stopPlayback":
        self.metronome.stopPlayback()
        result("Stopped playback")
      case "setBpm":
        let bpm: UInt16 = UInt16(arguments[0])!
        self.metronome.setBpm(bpm: bpm)
        result("Updated BPM")
      case "addSubdivision":
        let key: String = arguments[0]
        let option: Int = Int(arguments[1])!
        self.metronome.addSubdivision(key: key, subdivision: Subdivision(option: option))
        result("Added subdivision")
      case "removeSubdivision":
        let key: String = arguments[0]
        self.metronome.removeSubdivision(key: key)
        result("Removed subdivision")
      case "setSubdivisionOption":
        let key: String = arguments[0]
        let option: Int = Int(arguments[1])!
        self.metronome.getSubdivision(key: key).setOption(option: option)
        result("Set subdivision option")
      case "setSubdivisionVolume":
        let key: String = arguments[0]
        let volume: Float = Float(arguments[1])!
        self.metronome.getSubdivision(key: key).setVolume(volume: volume)
        result("Set subdivision volume")
      default:
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func postFlutterInit(result: FlutterResult) {
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
    } catch {
      result("Failed to set AVAudioSession category")
    }
    
    result("Completed post Flutter initialization")
  }
}
