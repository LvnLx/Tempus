import AVFoundation

class Metronome {
  private var audioQueue: AudioQueueRef?
  private var audioBuffer: AudioQueueBufferRef?
  private let audioQueueOutputCallback: AudioQueueOutputCallback = { (inUserData, inAQ, inBuffer) in
    AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, nil)
  }
  
  private let sampleRate: Float64 = 44100.0
  private let sizeOfFloat: UInt32 = UInt32(MemoryLayout<Float>.size)
  
  private var downbeatLocations: [UnsafeMutableRawPointer] = []
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
    
    let audioData: [Float] = [Float](repeating: 0.0, count: Int(audioBuffer!.pointee.mAudioDataByteSize))
    audioBuffer!.pointee.mAudioData.copyMemory(from: audioData, byteCount: Int(audioBuffer!.pointee.mAudioDataByteSize))
  }
  
  func getSubdivision(key: String) -> Subdivision {
    return subdivisions[key]!
  }
  
  func addSubdivision(key: String, subdivision: Subdivision) {
    subdivisions[key] = subdivision
    writeSubdivision(subdivision: subdivision)
  }
  
  func writeSubdivision(subdivision: Subdivision) {
    var startFrames: [UInt32] = Array(repeating: audioBuffer!.pointee.mAudioDataByteSize / sizeOfFloat / UInt32(subdivision.option), count: subdivision.option - 1)
    for (index, startFrame) in startFrames.enumerated() {
      startFrames[index] = startFrame * UInt32(index + 1)
    }
    
    for startFrame in startFrames {
      let start: UnsafeMutableRawPointer = audioBuffer!.pointee.mAudioData + Int(startFrame * sizeOfFloat)
      let samplesWritten: UInt32 = copyAudio(fileName: "Subdivision", outputBuffer: start)
      
      for sample in 0..<samplesWritten {
        let current: UnsafeMutableRawPointer = start + Int(sample * sizeOfFloat)
        current.storeBytes(of: current.load(as: Float.self) * subdivision.volume, as: Float.self)
        subdivision.locations.append(current)
      }
    }
  }
  
  func removeSubdivision(key: String) {
    eraseSubdivision(subdivision: subdivisions[key]!)
    subdivisions.removeValue(forKey: key)
  }
  
  func eraseSubdivision(subdivision: Subdivision) {
    for location in subdivision.locations {
      location.storeBytes(of: 0.0, as: Float.self)
    }
    subdivision.locations.removeAll()
  }
  
  func writeDownbeat() {
    for downbeatLocation in downbeatLocations {
      downbeatLocation.storeBytes(of: 0.0, as: Float.self)
    }
    downbeatLocations.removeAll()
    
    let start: UnsafeMutableRawPointer = audioBuffer!.pointee.mAudioData
    let samplesWritten: UInt32 = copyAudio(fileName: "Downbeat", outputBuffer: start)
    
    for sample in 0..<samplesWritten {
      let current: UnsafeMutableRawPointer = start + Int(sample * sizeOfFloat)
      current.storeBytes(of: current.load(as: Float.self) * 1.0, as: Float.self)
      downbeatLocations.append(current)
    }
  }
  
  func setBpm(bpm: UInt16) {
    let bps: Double = Double(bpm) / 60.0
    let beatDurationSeconds: Double = 1.0 / bps
    for subdivision in subdivisions.values {
      eraseSubdivision(subdivision: subdivision)
    }
    audioBuffer?.pointee.mAudioDataByteSize = UInt32(beatDurationSeconds * sampleRate * Double(sizeOfFloat))
    for subdivision in subdivisions.values {
      writeSubdivision(subdivision: subdivision)
    }
  }
  
  func setVolume(volume: Float) {
    AudioQueueSetParameter(audioQueue!, kAudioQueueParam_Volume, volume)
  }
  
  func startPlayback() {
    AudioQueueEnqueueBuffer(audioQueue!, audioBuffer!, 0, nil)
    AudioQueueEnqueueBuffer(audioQueue!, audioBuffer!, 0, nil) // Pre-fill buffer
    AudioQueueStart(audioQueue!, nil)
  }
  
  func stopPlayback() {
    AudioQueueStop(audioQueue!, true)
  }
}
