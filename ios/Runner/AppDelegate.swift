import UIKit
import Flutter
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  let angularFrequency: Double = 2.0 * Double.pi * 880.0
  var audioQueue: AudioQueueRef?
  var audioBuffer: AudioQueueBufferRef?
  var methodChannel: FlutterMethodChannel!
  let sampleRate: Float64 = 44100.0
  let sizeOfFloat: UInt32 = UInt32(MemoryLayout<Float>.size)
  
  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
    
    methodChannel = FlutterMethodChannel(name: "audio_method_channel", binaryMessenger: controller.binaryMessenger)
    methodChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      let arguments = call.arguments as? [String] ?? []
      
      switch call.method {
      case "configureAudioBuffer":
        self.configureAudioBuffer(result: result)
      case "postFlutterInit":
        self.postFlutterInit(result: result)
      case "startPlayback":
        self.startPlayback(result: result)
      case "stopPlayback":
        self.stopPlayback(result: result)
      case "updateBpm":
        self.updateBpm(result: result, arguments: arguments)
      default:
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func configureAudioBuffer(result: FlutterResult) {
    var audioData: [Float] = [Float](repeating: 0.0, count: Int(audioBuffer!.pointee.mAudioDataByteSize))
    
    for frame in 0..<Int(sampleRate * 0.05) {
      let time = Double(frame) / sampleRate
      let value = sin(angularFrequency * time)
      audioData[frame] = Float(value)
    }
    
    audioBuffer!.pointee.mAudioData.copyMemory(from: audioData, byteCount: Int(audioBuffer!.pointee.mAudioDataByteSize))
    
    result("Configured audio buffer")
  }
  
  private func postFlutterInit(result: FlutterResult) {
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
    } catch {
      result("Failed to set AVAudioSession category")
    }
    
    var audioStreamBasicDescription: AudioStreamBasicDescription = AudioStreamBasicDescription(
      mSampleRate: sampleRate,
      mFormatID: kAudioFormatLinearPCM,
      mFormatFlags: kLinearPCMFormatFlagIsFloat | kLinearPCMFormatFlagIsPacked,
      mBytesPerPacket: sizeOfFloat,
      mFramesPerPacket: 1,
      mBytesPerFrame: sizeOfFloat,
      mChannelsPerFrame: 1,
      mBitsPerChannel: sizeOfFloat * 8,
      mReserved: 0
    )
    
    AudioQueueNewOutput(&audioStreamBasicDescription, audioQueueOutputCallback, nil, nil, nil, 0, &audioQueue)
    
    AudioQueueSetParameter(audioQueue!, kAudioQueueParam_Pan, 0.0)
    AudioQueueSetParameter(audioQueue!, kAudioQueueParam_PlayRate, 1.0)
    AudioQueueSetParameter(audioQueue!, kAudioQueueParam_VolumeRampTime, 0.0)
    AudioQueueSetParameter(audioQueue!, kAudioQueueParam_Volume, 1.0)
    
    let bufferSize: UInt32 = sizeOfFloat * UInt32(sampleRate) * 60 // 60 seconds = 1 beat per minute
    AudioQueueAllocateBuffer(audioQueue!, bufferSize, &audioBuffer)
                           
    result("Completed post Flutter initialization")
  }
  
  let audioQueueOutputCallback: AudioQueueOutputCallback = { (inUserData, inAQ, inBuffer) in
    AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, nil)
  }
  
  private func updateBpm(result: FlutterResult, arguments: [String]) {
    let bpm: UInt16 = UInt16(arguments[0]) ?? 0
    let bps: Double = Double(bpm) / 60.0
    let beatDurationSeconds: Double = 1.0 / bps
    audioBuffer?.pointee.mAudioDataByteSize = UInt32(beatDurationSeconds * sampleRate * Double(sizeOfFloat))
    
    result("Updated BPM")
  }
  
  private func startPlayback(result: FlutterResult) {
    AudioQueueStart(audioQueue!, nil)
    AudioQueueEnqueueBuffer(audioQueue!, audioBuffer!, 0, nil)
    AudioQueueEnqueueBuffer(audioQueue!, audioBuffer!, 0, nil) // Pre-fill buffer
    
    result("Started playback")
  }
  
  private func stopPlayback(result: FlutterResult) {
    AudioQueueStop(audioQueue!, true)
    
    result("Stopped playback")
  }
}
