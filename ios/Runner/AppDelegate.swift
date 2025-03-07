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
    metronome = Metronome(self.beatStarted)
    
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
      case "setAppVolume":
        let volume: Float = Float(arguments[0])!
        self.metronome.setAppVolume(volume)
        result("Set app volume")
      case "setBpm":
        let bpm: UInt16 = UInt16(arguments[0])!
        self.metronome.setBpm(bpm)
        result("Set BPM")
      case "setBeatSample":
        let path: String = arguments[0]
        self.metronome.setBeatSample(path)
        result("Set beat sample")
      case "setBeatVolume":
        let volume: Float = Float(arguments[0])!
        // TODO set beat volume
        result("Set beat volume")
      case "setDenominator":
        let bpm: UInt16 = UInt16(arguments[0])!
        // TODO set denominator
        result("Set denominator")
      case "setDownbeatVolume":
        let volume: Float = Float(arguments[0])!
        // TODO set downbeat volume
        result("Set downbeat volume")
      case "setInnerBeatSample":
        let path: String = arguments[0]
        self.metronome.setInnerBeatSample(path)
        result("Set inner beat sample")
      case "setNumerator":
        let bpm: UInt16 = UInt16(arguments[0])!
        // TODO set numerator
        result("Set numerator")
      case "setSamplePaths":
        for samplePath in arguments {
          loadAudioFile(samplePath, controller.lookupKey(forAsset: samplePath))
        }
        result("Set sample names")
      case "setState":
        let appVolume: Float = Float(arguments[0])!
        let bpm: UInt16 = UInt16(arguments[1])!
        let beatVolume: Float = Float(arguments[2])!
        let denominator: UInt16 = UInt16(arguments[3])!
        let downbeatVolume: Float = Float(arguments[4])!
        let numerator: UInt16 = UInt16(arguments[5])!
        let beatSamplePath: String = arguments[6]
        let innerBeatSamplePath: String = arguments[7]
        let subdivisionsAsJsonString: String = arguments[8]
        self.metronome.setState(appVolume, bpm, beatVolume, denominator, downbeatVolume, numerator, beatSamplePath, innerBeatSamplePath, subdivisionsAsJsonString)
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
  
  func beatStarted() {
    DispatchQueue.main.async {
      self.methodChannel.invokeMethod("beatStarted", arguments: nil)
    }
  }
}
