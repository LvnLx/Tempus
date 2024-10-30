import AVFoundation

class Metronome {
  private var audioQueue: AudioQueueRef?
  private var audioBuffer: AudioQueueBufferRef?
  private let audioQueueOutputCallback: AudioQueueOutputCallback = { (inUserData, inAQ, inBuffer) in
    AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, nil)
  }
  
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
    
    let audioData: [Float] = [Float](repeating: 0.0, count: Int(audioBuffer!.pointee.mAudioDataByteSize))
    audioBuffer!.pointee.mAudioData.copyMemory(from: audioData, byteCount: Int(audioBuffer!.pointee.mAudioDataByteSize))
  }
  
  func addSubdivision(key: String, option: Int, volume: Float) {
    subdivisions[key] = Subdivision(option: option, volume: volume)
    // TODO
  }
  
  /*
  func writeAllSubdivisions() {
    for subdivision in subdivisions.values {
      writeSubdivision(subdivision: subdivision)
    }
  }
  
  func writeSubdivision(subdivision: Subdivision) {
    if (subdivisions.values.contains(where: { $0.option == subdivision.option && $0.volume > subdivision.volume })) {
      return
    }
    
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
  }*/
  
  func removeSubdivision(key: String) {
    deleteAudio(locationGroups: subdivisions[key]!.locationGroups)
    subdivisions.removeValue(forKey: key)
  }
  
  func setBpm(bpm: UInt16) {
    // TODO
    let bps: Double = Double(bpm) / 60.0
    let beatDurationSeconds: Double = 1.0 / bps
    
    for subdivision in subdivisions.values {
      deleteAudio(locationGroups: subdivision.locationGroups)
      subdivision.locationGroups.removeAll()
    }
    audioBuffer?.pointee.mAudioDataByteSize = UInt32(beatDurationSeconds * sampleRate * Double(sizeOfFloat))
    writeAllSubdivisions()
  }
  
  func setSubdivisionOption(key: String, option: Int) {
    // TODO
  }
  
  func setSubdivisionVolume(key: String, volume:Float) {
    // TODO
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
  
  func writeDownbeat() {
    // TODO
    /*
    let start: UnsafeMutableRawPointer = audioBuffer!.pointee.mAudioData
    let samplesWritten: UInt32 = copyAudio(fileName: "Downbeat", outputBuffer: start)
    
    for sample in 0..<samplesWritten {
      let current: UnsafeMutableRawPointer = start + Int(sample * sizeOfFloat)
      current.storeBytes(of: current.load(as: Float.self), as: Float.self)
    }*/
  }
  
  private func getNonDominatedLocationGroups(subdivision: Subdivision) -> [UnsafeMutableRawPointer] {
    subdivision.locationGroups.filter({
      let heads = this.subdivisions.values
        .filter({ $0 !== subdivision && max($0.option, subdivision.option) % min($0.option, subdivision.option) == 0 && $0.volume < subdivision.volume })
        .flatMap({ $0.locationGroups })
        .flatMap({ $0.first! })
      heads.contains($0.first!)
    })
  }
  
  private func deleteAudio(locationGroups: [[UnsafeMutableRawPointer]]) {
    for locationGroup in locationGroups {
      for location in locationGroup {
        location.storeBytes(of: 0.0, as: Float.self)
      }
    }
  }
  
  private func writeAllSubdivisions() {
    
  }
  
  private func writeAudio() {
    
  }
}
