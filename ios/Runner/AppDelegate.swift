import UIKit
import Flutter
import AVFoundation

struct MetronomeSettings {
  let bpm: Int
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
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
      case"startPlayback":
        self.startPlayback(result: result)
      case "stopPlayback":
        self.stopPlayback(result: result)
      case "configureAudioBuffer":
        self.configureAudioBuffer(result: result, arguments: arguments)
      default:
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func postFlutterInit(result: FlutterResult) {audioEngine = AVAudioEngine()
    audioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 1)
    audioBuffer = AVAudioPCMBuffer(pcmFormat: audioFormat, frameCapacity: UInt32(audioFormat.sampleRate))

    audioPlayerNode = AVAudioPlayerNode()
    audioEngine.attach(audioPlayerNode)
    audioEngine.connect(audioPlayerNode, to: audioEngine.outputNode, format: audioFormat)
    
    do {
      try audioEngine.start()
    } catch {
      result("Error starting AVAudioEngine: \(error.localizedDescription)")
      return
    }
    
    result("Completed post Flutter initialization")
  }
  
  private func startPlayback(result: FlutterResult) {
    audioPlayerNode.scheduleBuffer(audioBuffer)
    audioPlayerNode.play()
    result("Started playback")
  }
  
  private func stopPlayback(result: FlutterResult) {
    audioPlayerNode.stop()
    result("Stopped playback")
  }
  
  private func configureAudioBuffer(result: FlutterResult, arguments: [String]) {
    let frequency: Double = 440.0
    let amplitude: Double = 1.0
    let angularFrequency: Double = 2.0 * Double.pi * frequency
    
    for frame in 0..<Int(audioBuffer.frameCapacity) {
      let time = Double(frame) / audioFormat.sampleRate
      let value = sin(angularFrequency * time) * amplitude
      audioBuffer.floatChannelData?.pointee[frame] = Float(value)
    }
    
    audioBuffer.frameLength = audioBuffer.frameCapacity
    
    result("Configured audio buffer")
  }
}
