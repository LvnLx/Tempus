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
        let subdivisions: [String: Subdivision] = self.subdivisionsFromJsonString(arguments[6])
        let timeSignature: TimeSignature = TimeSignature(arguments[7])
        
        self.metronome.setAppVolume(appVolume, false)
        self.metronome.setBeatUnit(beatUnit, false, false)
        self.metronome.setBeatVolume(beatVolume, false)
        self.metronome.setBpm(bpm, false, false)
        self.metronome.setDownbeatVolume(downbeatVolume, false)
        self.metronome.setSampleSet(sampleSet, false)
        self.metronome.setSubdivisions(subdivisions, false)
        self.metronome.setTimeSignature(timeSignature, false, false)
        
        self.metronome.updateValidFrameCount(true)
        self.metronome.updateClips()
        
        result("Set state")
      case "setSubdivisions":
        let subdivisions: [String: Subdivision] = self.subdivisionsFromJsonString(arguments[0])
        self.metronome.setSubdivisions(subdivisions)
        result("Set subdivisions")
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
      
  private func subdivisionsFromJsonString(_ subdivisionsAsJsonString: String) -> [String: Subdivision] {
    let subdivisionsAsData: Data? = subdivisionsAsJsonString.data(using: .utf8)
    let subdivisionsAsJson: [String: [String: Any]] = try! JSONSerialization.jsonObject(with: subdivisionsAsData!) as! [String: [String: Any]]
    return subdivisionsAsJson.reduce(into: [String: Subdivision]()) { accumulator, element in
      accumulator[element.key] = Subdivision(element.value)
    }
  }
}
