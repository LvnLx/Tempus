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
        self.metronome.addSubdivision(key: key, subdivision: Subdivision(option: option, volume: volume))
        result("Added subdivision")
      case "removeSubdivision":
        let key: String = arguments[0]
        self.metronome.removeSubdivision(key: key)
        result("Removed subdivision")
      case "setBpm":
        let bpm: UInt16 = UInt16(arguments[0])!
        self.metronome.setBpm(bpm: bpm)
        result("Set BPM")
      case "setSubdivisionOption":
        let key: String = arguments[0]
        let option: Int = Int(arguments[1])!
        let subdivision: Subdivision = self.metronome.getSubdivision(key: key)
        self.metronome.eraseSubdivision(subdivision: subdivision)
        subdivision.setOption(option: option)
        self.metronome.writeSubdivision(subdivision: subdivision)
        result("Set subdivision option")
      case "setSubdivisionVolume":
        let key: String = arguments[0]
        let volume: Float = Float(arguments[1])!
        let subdivision: Subdivision = self.metronome.getSubdivision(key: key)
        subdivision.setVolume(volume: volume)
        self.metronome.writeSubdivision(subdivision: subdivision)
        result("Set subdivision volume")
      case "setVolume":
        let volume: Float = Float(arguments[0])!
        self.metronome.setVolume(volume: volume)
        result("Set volume")
      case "startPlayback":
        self.metronome.startPlayback()
        result("Started playback")
      case "stopPlayback":
        self.metronome.stopPlayback()
        result("Stopped playback")
      case "writeDownbeat":
        self.metronome.writeDownbeat()
        result("Wrote downbeat")
      default:
        result(FlutterMethodNotImplemented)
      }
    })
      
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
    } catch {
      print("Failed to set AVAudioSession's shared instance category")
    }
    
    loadAudioFile(fileName: "Downbeat")
    loadAudioFile(fileName: "Subdivision")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
