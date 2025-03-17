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
      case "setBeatUnit":
        let beatUnit: BeatUnit = BeatUnit(arguments[0])
        self.metronome.setBeatUnit(beatUnit)
        result("Set beat unit")
      case "setBeatVolume":
        let volume: Float = Float(arguments[0])!
        self.metronome.setBeatVolume(volume)
        result("Set beat volume")
      case "setDownbeatVolume":
        let volume: Float = Float(arguments[0])!
        self.metronome.setDownbeatVolume(volume)
        result("Set downbeat volume")
      case "setSamplePaths":
        for samplePath in arguments {
          loadAudioFile(samplePath, controller.lookupKey(forAsset: samplePath))
        }
        result("Set sample names")
      case "setSampleSet":
        let sampleSet: SampleSet = SampleSet(arguments[0])
        self.metronome.setSampleSet(sampleSet)
        result("Set sample set")
      case "setState":
        let appVolume: Float = Float(arguments[0])!
        let bpm: UInt16 = UInt16(arguments[1])!
        let beatUnit: BeatUnit = BeatUnit(arguments[2])
        let beatVolume: Float = Float(arguments[3])!
        let downbeatVolume: Float = Float(arguments[4])!
        let sampleSet: SampleSet = SampleSet(arguments[5])
        let subdivisionsAsJsonString: String = arguments[6]
        let timeSignature: TimeSignature = TimeSignature(arguments[7])
        
        self.metronome.setAppVolume(appVolume, false)
        self.metronome.setBeatUnit(beatUnit, false, false)
        self.metronome.setBeatVolume(beatVolume, false)
        self.metronome.setBpm(bpm, false, false)
        self.metronome.setDownbeatVolume(downbeatVolume, false)
        self.metronome.setSampleSet(sampleSet, false)
        self.metronome.setTimeSignature(timeSignature, false, false)
        self.metronome.setState(subdivisionsAsJsonString)
        
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
      case "setTimeSignature":
        let timeSignature: TimeSignature = TimeSignature(arguments[0])
        self.metronome.setTimeSignature(timeSignature)
        result("Set time signature")
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
