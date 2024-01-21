import UIKit
import Flutter
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  let angularFrequency: Double = 2.0 * Double.pi * 440.0
  var audioBuffer: AVAudioPCMBuffer!
  var audioEngine: AVAudioEngine!
  var audioFormat: AVAudioFormat!
  var audioPlayerNode: AVAudioPlayerNode!
  var methodChannel: FlutterMethodChannel!
  
  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    
    methodChannel = FlutterMethodChannel(name: "audio_method_channel", binaryMessenger: controller.binaryMessenger)
    methodChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      let arguments = call.arguments as? [String] ?? []
      
      switch call.method {
      case "postFlutterInit":
        self.postFlutterInit(result: result)
      case "updateBpm":
        self.updateBpm(result: result, arguments: arguments)
      case "startPlayback":
        self.startPlayback(result: result)
      case "stopPlayback":
        self.stopPlayback(result: result)
      case "configureAudioBuffer":
        self.configureAudioBuffer(result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func postFlutterInit(result: FlutterResult) {audioEngine = AVAudioEngine()
    audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1)
    let frameCapacity: UInt32 = UInt32(audioFormat.sampleRate * 10) // 60 seconds = 1 bpm
    audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: frameCapacity)
    
    audioPlayerNode = AVAudioPlayerNode()
    audioEngine.attach(audioPlayerNode)
    audioEngine.connect(audioPlayerNode, to: audioEngine.outputNode, format: audioFormat)
    
    do {
      try audioEngine.start()
    } catch {
      result("Error starting AVAudioEngine: \(error.localizedDescription)")
      return
    }
    
    schedulePlayback()
    
    result("Completed post Flutter initialization")
  }
  
  private func schedulePlayback() {
    audioPlayerNode.scheduleBuffer(audioBuffer, at: nil, completionHandler: {() -> Void in
      DispatchQueue.main.async {
        self.schedulePlayback()
      }
    })
  }
  
  private func updateBpm(result: FlutterResult, arguments: [String]) {
    let bpm: UInt16 = UInt16(arguments[0]) ?? 0
    let bps: Double = Double(bpm) / 60.0
    let beatDurationPerSecond: Double = 1.0 / bps
    audioBuffer.frameLength = UInt32(beatDurationPerSecond * audioFormat.sampleRate)
    
    result("Updated BPM")
  }
  
  private func startPlayback(result: FlutterResult) {
    audioPlayerNode.play()
    result("Started playback")
  }
  
  private func stopPlayback(result: FlutterResult) {
    self.audioPlayerNode.stop()
    result("Stopped playback")
  }
  
  private func configureAudioBuffer(result: FlutterResult) {
    for frame in 0..<Int(audioFormat.sampleRate * 0.05) {
      let time = Double(frame) / audioFormat.sampleRate
      let value = sin(angularFrequency * time)
      audioBuffer.floatChannelData?.pointee[frame] = Float(value)
    }
    
    result("Configured audio buffer")
  }
}
