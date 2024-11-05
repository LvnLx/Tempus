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
      case "addSubdivision":
        let key: String = arguments[0]
        let option: Int = Int(arguments[1])!
        let volume: Float = Float(arguments[2])!
        self.metronome.addSubdivision(key, option, volume)
        result("Added subdivision")
      case "removeSubdivision":
        let key: String = arguments[0]
        self.metronome.removeSubdivision(key)
        result("Removed subdivision")
      case "setBpm":
        let bpm: UInt16 = UInt16(arguments[0])!
        self.metronome.setBpm(bpm)
        result("Set BPM")
      case "setSubdivisionOption":
        let key: String = arguments[0]
        let option: Int = Int(arguments[1])!
        self.metronome.setSubdivisionOption(key, option)
        result("Set subdivision option")
      case "setSubdivisionVolume":
        let key: String = arguments[0]
        let volume: Float = Float(arguments[1])!
        self.metronome.setSubdivisionVolume(key, volume)
        result("Set subdivision volume")
      case "setVolume":
        let volume: Float = Float(arguments[0])!
        self.metronome.setVolume(volume)
        result("Set volume")
      case "startPlayback":
        self.metronome.startPlayback()
        result("Started playback")
      case "stopPlayback":
        self.metronome.stopPlayback()
        result("Stopped playback")
      case "writeBuffer":
        self.metronome.writeBuffer()
        result("Wrote buffer")
      default:
        result(FlutterMethodNotImplemented)
      }
    })
      
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
    } catch {
      print("Failed to set AVAudioSession's shared instance category")
    }
    
    loadAudioFile("Downbeat")
    loadAudioFile("Subdivision")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
