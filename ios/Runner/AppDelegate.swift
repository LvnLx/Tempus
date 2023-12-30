import UIKit
import Flutter
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  var audioPlayer: AVAudioPlayer!
  
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
    
    guard
      let url = Bundle.main.url(forResource: "Limbo", withExtension: "mp3")
    else {
      print("Error opening audio file")
      return false
    }
    
    do {
      try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.mixWithOthers)
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      print("Error setting up AVAudioSession: \(error.localizedDescription)")
      return false
    }
    
    do {
      audioPlayer = try AVAudioPlayer(contentsOf: url)
    } catch {
      print("Error setting up AVAudioPlayer: \(error.localizedDescription)")
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func startPlayback (result: FlutterResult) {
    audioPlayer.play()
    /*
     
     do {
     audioFile = try AVAudioFile(forReading: url)
     } catch {
     print(error.localizedDescription)
     return
     }
     
     let audioEngine: AVAudioEngine = AVAudioEngine()
     let audioPlayerNode: AVAudioPlayerNode = AVAudioPlayerNode()
     
     audioEngine.attach(audioPlayerNode)
     audioEngine.connect(audioPlayerNode, to: audioEngine.outputNode, format: audioFile.processingFormat)
     
     audioPlayerNode.scheduleFile(audioFile, at: nil)
     
     do {
     try audioEngine.start()
     audioPlayerNode.play()
     } catch {
     print(error.localizedDescription)
     }*/
    
    
    
    result("started")
  }
  
  private func stopPlayback(result: FlutterResult) {
    audioPlayer.pause()
    result("stopped")
  }
}
