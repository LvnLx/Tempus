import AVFoundation

class Metronome {
  private var audioQueue: AudioQueueRef?
  private var audioBuffer: AudioQueueBufferRef?
  private let audioQueueOutputCallback: AudioQueueOutputCallback = { (inUserData, inAQ, inBuffer) in
    AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, nil)
  }
  
  private let angularFrequency: Double = 2.0 * Double.pi * 880.0
  private let sampleRate: Float64 = 44100.0
  private let sizeOfFloat: UInt32 = UInt32(MemoryLayout<Float>.size)
    
  private var subdivisions: [String: Subdivision] = [:]
  
  init() {
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
  }
  
  func addSubdivision(key: String, subdivision: Subdivision) {
    self.subdivisions[key] = subdivision
  }
  
  func getSubdivision(key: String) -> Subdivision {
    return self.subdivisions[key]!
  }
  
  func removeSubdivision(key: String) {
    self.subdivisions.removeValue(forKey: key)
  }
  
  func writeAudioBuffer() {
    var audioData: [Float] = [Float](repeating: 0.0, count: Int(audioBuffer!.pointee.mAudioDataByteSize))
    
    for frame in 0..<Int(sampleRate * 0.05) {
      let time = Double(frame) / sampleRate
      let value = sin(angularFrequency * time)
      audioData[frame] = Float(value)
    }
    
    for (_, subdivision) in subdivisions {
      if (subdivision.volume == 0) {
        continue
      }
      
      var startFrames: [UInt32] = Array(repeating: audioBuffer!.pointee.mAudioDataByteSize / sizeOfFloat / UInt32(subdivision.option), count: subdivision.option - 1)
      for (index, startFrame) in startFrames.enumerated() {
        startFrames[index] = startFrame * UInt32(index + 1)
      }
      
      for startFrame in startFrames {
        let sampleLength = UInt32(sampleRate * 0.05)
        let endFrame = Int(startFrame + sampleLength)
        for frame in Int(startFrame)..<endFrame {
          let time = Double(frame) / sampleRate
          let value = sin(Float(angularFrequency * time)) * subdivision.volume
          print(subdivision.volume)
          audioData[frame] = Float(value)
        }
      }
    }
    
    audioBuffer!.pointee.mAudioData.copyMemory(from: audioData, byteCount: Int(audioBuffer!.pointee.mAudioDataByteSize))
  }
  
  func setBpm(bpm: UInt16) {
    let bps: Double = Double(bpm) / 60.0
    let beatDurationSeconds: Double = 1.0 / bps
    audioBuffer?.pointee.mAudioDataByteSize = UInt32(beatDurationSeconds * sampleRate * Double(sizeOfFloat))
  }
  
  func startPlayback() {
    AudioQueueStart(audioQueue!, nil)
    AudioQueueEnqueueBuffer(audioQueue!, audioBuffer!, 0, nil)
    AudioQueueEnqueueBuffer(audioQueue!, audioBuffer!, 0, nil) // Pre-fill buffer
  }
  
  func stopPlayback() {
    AudioQueueStop(audioQueue!, true)
  }
}
