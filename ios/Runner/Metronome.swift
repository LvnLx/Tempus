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
  
  func addSubdivision(_ key: String, _ option: Int, _ volume: Float) {
    let subdivision = Subdivision(option, volume)
    subdivisions[key] = subdivision
    
    let locationsToWriteAudio = getAffectedLocations(subdivision)
    writeAudio(locationsToWriteAudio)
  }
  
  func removeSubdivision(_ key: String) {
    let subdivision = subdivisions[key]!
    
    let locationsToWriteAudio = getAffectedLocations(subdivision)
    subdivisions.removeValue(forKey: key)
    writeAudio(locationsToWriteAudio)
  }
  
  func setBpm(_ bpm: UInt16) {
    let bps: Double = Double(bpm) / 60.0
    let beatDurationSeconds: Double = 1.0 / bps
    
    
    let allLocations = Array(Set(subdivisions.values.flatMap({ $0.locations })))
    deleteAudio(allLocations)
    audioBuffer!.pointee.mAudioDataByteSize = UInt32(beatDurationSeconds * sampleRate * Double(sizeOfFloat))
    writeAudio(allLocations)
  }
  
  func setSubdivisionOption(_ key: String, _ option: Int) {
    let subdivision = subdivisions[key]!
    
    var locationsToWriteAudio = getAffectedLocations( subdivision)
    subdivision.setOption(option: option)
    locationsToWriteAudio.append(contentsOf: getAffectedLocations(subdivision))
    writeAudio(locationsToWriteAudio)
  }
  
  func setSubdivisionVolume(_ key: String, _ volume: Float) {
    let subdivision = subdivisions[key]!
    subdivision.setVolume(volume: volume)
    
    let locationsToWriteAudio = getAffectedLocations(subdivision)
    writeAudio(locationsToWriteAudio)
  }
  
  func setVolume(_ volume: Float) {
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
    let start: UnsafeMutableRawPointer = audioBuffer!.pointee.mAudioData
    let samplesWritten: UInt32 = copyAudio("Downbeat", start)
    
    for sample in 0..<samplesWritten {
      let current: UnsafeMutableRawPointer = start + Int(sample * sizeOfFloat)
      current.storeBytes(of: current.load(as: Float.self), as: Float.self)
    }
  }
  
  private func getAffectedLocations(_ subdivision: Subdivision) -> [Double] {
    subdivision.locations.filter({ location in
      subdivisions.values
        .filter({ $0 !== subdivision && $0.locations.contains(location) })
        .allSatisfy({ $0.volume <= subdivision.volume })
    })
  }
  
  private func deleteAudio(_ locations: [Double]) {
    for location in locations {
      let exactLocation: Double = Double(audioBuffer!.pointee.mAudioDataByteSize / sizeOfFloat) * location
      let startFrame: UInt32 = UInt32((exactLocation / Double(sizeOfFloat)).rounded()) * sizeOfFloat
      let start: UnsafeMutableRawPointer = audioBuffer!.pointee.mAudioData + Int(startFrame * sizeOfFloat)

      for sample in 0..<getAudioLength("Subdivision") {
        let current: UnsafeMutableRawPointer = start + Int(sample * sizeOfFloat)
        current.storeBytes(of: 0, as: Float.self)
      }
    }
  }
  
  private func writeAudio(_ locations: [Double]) {
    for location in locations {
      let volume = subdivisions.values
        .filter({ $0.locations.contains(location) })
        .max(by: { $0.volume < $1.volume } )?
        .volume ?? 0
      
      let exactLocation: Double = Double(audioBuffer!.pointee.mAudioDataByteSize / sizeOfFloat) * location
      let startFrame: UInt32 = UInt32((exactLocation / Double(sizeOfFloat)).rounded()) * sizeOfFloat
      let start: UnsafeMutableRawPointer = audioBuffer!.pointee.mAudioData + Int(startFrame * sizeOfFloat)
      let samplesWritten: UInt32 = copyAudio("Subdivision", start)

      for sample in 0..<samplesWritten {
        let current: UnsafeMutableRawPointer = start + Int(sample * sizeOfFloat)
        current.storeBytes(of: current.load(as: Float.self) * volume, as: Float.self)
      }
    }
  }
}
