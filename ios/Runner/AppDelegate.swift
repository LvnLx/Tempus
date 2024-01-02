import UIKit
import Flutter
import AVFoundation

struct MetronomeSettings {
  let bpm: Int
}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  var audioEngine: AVAudioEngine!
  var audioFile: AVAudioFile!
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
    audioPlayerNode = AVAudioPlayerNode()
    
    do {
      guard
        let url = Bundle.main.url(forResource: "Limbo", withExtension: "mp3")
      else {
        result("Error opening audio file")
        return
      }
      audioFile = try AVAudioFile(forReading: url)
    } catch {
      result("Error getting AVAudioFile: \(error.localizedDescription)")
      return
    }
    
    audioEngine.attach(audioPlayerNode)
    audioEngine.connect(audioPlayerNode, to: audioEngine.outputNode, format: audioFile.processingFormat)
    
    do {
      try audioEngine.start()
    } catch {
      result("Error starting AVAudioEngine: \(error.localizedDescription)")
      return
    }
    
    result("Completed post Flutter initialization")
  }
  
  private func startPlayback(result: FlutterResult) {
    audioPlayerNode.scheduleFile(audioFile, at: nil)
    audioPlayerNode.play()
    result("Started playback")
  }
  
  private func stopPlayback(result: FlutterResult) {
    audioPlayerNode.stop()
    result("Stopped playback")
  }
  
  private func configureAudioBuffer(result: FlutterResult, arguments: [String]) {
    result("Configured audio buffer")
  }
}
