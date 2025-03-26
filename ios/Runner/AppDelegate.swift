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
    metronome = Metronome(self.beatStarted, self.downbeatStarted, self.innerBeatStarted)
    
    methodChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      let arguments = call.arguments as? [String] ?? []
      
      switch call.method {
      case "initializeMetronome":
        self.metronome.updateValidFrameCount(true)
        self.metronome.updateClips()
        result("Initialized metronome")
      case "setAppVolume":
        let volume: Float = Float(arguments[0])!
        let isMetronomeInitialization: Bool = Bool(arguments[1])!
        self.metronome.setAppVolume(volume, isMetronomeInitialization)
        result("Set app volume")
      case "setBpm":
        let bpm: UInt16 = UInt16(arguments[0])!
        let isMetronomeInitialization: Bool = Bool(arguments[1])!
        self.metronome.setBpm(bpm, isMetronomeInitialization)
        result("Set BPM")
      case "setBeatUnit":
        let beatUnit: BeatUnit = BeatUnit(arguments[0])
        let isMetronomeInitialization: Bool = Bool(arguments[1])!
        self.metronome.setBeatUnit(beatUnit, isMetronomeInitialization)
        result("Set beat unit")
      case "setBeatVolume":
        let volume: Float = Float(arguments[0])!
        let isMetronomeInitialization: Bool = Bool(arguments[1])!
        self.metronome.setBeatVolume(volume, isMetronomeInitialization)
        result("Set beat volume")
      case "setDownbeatVolume":
        let volume: Float = Float(arguments[0])!
        let isMetronomeInitialization: Bool = Bool(arguments[1])!
        self.metronome.setDownbeatVolume(volume, isMetronomeInitialization)
        result("Set downbeat volume")
      case "setPlayback":
        let value: Bool = Bool(arguments[0])!
        self.metronome.setPlayback(value)
        result("Set playback")
      case "setSamplePaths":
        for samplePath in arguments {
          loadAudioFile(samplePath, controller.lookupKey(forAsset: samplePath))
        }
        result("Set sample names")
      case "setSampleSet":
        let sampleSet: SampleSet = SampleSet(arguments[0])
        let isMetronomeInitialization: Bool = Bool(arguments[1])!
        self.metronome.setSampleSet(sampleSet, isMetronomeInitialization)
        result("Set sample set")
      case "setSubdivisions":
        let subdivisions: [String: Subdivision] = self.subdivisionsFromJsonString(arguments[0])
        let isMetronomeInitialization: Bool = Bool(arguments[1])!
        self.metronome.setSubdivisions(subdivisions, isMetronomeInitialization)
        result("Set subdivisions")
      case "setTimeSignature":
        let timeSignature: TimeSignature = TimeSignature(arguments[0])
        let isMetronomeInitialization: Bool = Bool(arguments[1])!
        self.metronome.setTimeSignature(timeSignature, isMetronomeInitialization)
        result("Set time signature")
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
  
  func beatStarted(_ count: Int) {
    DispatchQueue.main.async {
      self.methodChannel.invokeMethod("beatStarted", arguments: [String(count)])
    }
  }
  
  func downbeatStarted() {
    DispatchQueue.main.async {
      self.methodChannel.invokeMethod("downbeatStarted", arguments: nil)
    }
  }
  
  func innerBeatStarted() {
    DispatchQueue.main.async {
      self.methodChannel.invokeMethod("innerBeatStarted", arguments: nil)
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
