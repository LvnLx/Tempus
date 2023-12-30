import UIKit
import Flutter
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  var audioEngine: AVAudioEngine!
  var audioFile: AVAudioFile!
  var audioPlayerNode: AVAudioPlayerNode!
  
  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    let audio_method_channel = FlutterMethodChannel(name: "audio_method_channel", binaryMessenger: controller.binaryMessenger)
    audio_method_channel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "startPlayback" {
        self.startPlayback(result: result)
      } else if call.method == "stopPlayback" {
        self.stopPlayback(result: result)
      }
    })
    
    audioEngine = AVAudioEngine()
    audioPlayerNode = AVAudioPlayerNode()
    
    do {
      guard
        let url = Bundle.main.url(forResource: "Limbo", withExtension: "mp3")
      else {
        print("Error opening audio file")
        return false
      }
      audioFile = try AVAudioFile(forReading: url)
    } catch {
      print("Error getting AVAudioFile: \(error.localizedDescription)")
      return false
    } 
    
    audioEngine.attach(audioPlayerNode)
    audioEngine.connect(audioPlayerNode, to: audioEngine.outputNode, format: audioFile.processingFormat)
    
    do {
      try audioEngine.start()
    } catch {
      print("Error starting AVAudioEngine: \(error.localizedDescription)")
      return false
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func startPlayback(result: FlutterResult) {
    audioPlayerNode.scheduleFile(audioFile, at: nil)
    audioPlayerNode.play()
    result("started")
  }
  
  private func stopPlayback(result: FlutterResult) {
    audioPlayerNode.stop()
    result("stopped")
  }
}
