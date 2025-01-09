import UIKit
import Flutter
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var methodChannel: FlutterMethodChannel!
  private var metronome: Metronome!
  
  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    
    methodChannel = FlutterMethodChannel(name: "audio", binaryMessenger: controller.binaryMessenger)
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
      case "setSample":
        let isDownbeat: Bool = Bool(arguments[0])!
        let sampleName: String = arguments[1]
        self.metronome.setSample(isDownbeat, sampleName)
        result("Set sample")
      case "setSampleNames":
        for sampleName in arguments {
          loadAudioFile(sampleName, controller.lookupKey(forAsset: "audio/\(sampleName).wav"))
        }
        result("Set sample names")
      case "setState":
        let bpm: UInt16 = UInt16(arguments[0])!
        let downbeatSampleName: String = arguments[1]
        let subdivisionSampleName: String = arguments[2]
        let volume: Float = Float(arguments[3])!
        self.metronome.setState(bpm, downbeatSampleName, subdivisionSampleName, volume)
        result("Set state")
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
      default:
        result(FlutterMethodNotImplemented)
      }
    })
      
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
    } catch {
      print("Failed to set AVAudioSession's shared instance category")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
