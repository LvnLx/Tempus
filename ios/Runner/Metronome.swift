import AVFoundation

let sizeOfFloat: UInt32 = UInt32(MemoryLayout<Float>.size)
let sampleRate: Float64 = 44100.0

class Metronome {
  private var audioQueue: AudioQueueRef?
  private var audioBuffer: AudioQueueBufferRef?
  private let audioQueueOutputCallback: AudioQueueOutputCallback = { (inUserData, inAQ, inBuffer) in
    AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, nil)
  }
  
  private var bufferCallbacks: [(_ buffer: inout [Float]) -> Void] = []
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
    
    createBufferCallbacks()
  }
  
  func addSubdivision(_ key: String, _ option: Int, _ volume: Float) {
    let subdivision = Subdivision(option, volume)
    subdivisions[key] = subdivision
    
    writeBuffer()
  }
  
  func removeSubdivision(_ key: String) {
    let subdivision = subdivisions[key]!
    subdivisions.removeValue(forKey: key)

    writeBuffer()
  }
  
  func setBpm(_ bpm: UInt16) {
    let bps: Double = Double(bpm) / 60.0
    let beatDurationSeconds: Double = 1.0 / bps
    audioBuffer!.pointee.mAudioDataByteSize = UInt32(beatDurationSeconds * sampleRate * Double(sizeOfFloat))
    
    writeBuffer()
  }
  
  func setSubdivisionOption(_ key: String, _ option: Int) {
    let subdivision = subdivisions[key]!
    subdivision.setOption(option)
    
    writeBuffer()
  }
  
  func setSubdivisionVolume(_ key: String, _ volume: Float) {
    let subdivision = subdivisions[key]!
    subdivision.setVolume(volume)
    
    writeBuffer()
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
  
  func writeBuffer() {
    var buffer: [Float] = Array(repeating: 0, count: Int(audioBuffer!.pointee.mAudioDataByteSize) / Int(sizeOfFloat))
    
    for bufferCallback in bufferCallbacks {
      bufferCallback(&buffer)
    }
    
    audioBuffer!.pointee.mAudioData.copyMemory(from: buffer, byteCount: buffer.count * Int(sizeOfFloat))
  }
  
  private func createBufferCallbacks() {
    bufferCallbacks.append { buffer in
      for (index, sample) in downbeatAudio.enumerated() {
        buffer[index] += sample
      }
    }
    
    bufferCallbacks.append { buffer in
      var locationVolumes: [Float:Float] = self.subdivisions.values.reduce(into: [:]) {(accumulator, subdivision) in
        for location in subdivision.getLocations() {
          if (subdivision.volume >= accumulator[location] ?? 0) {
            accumulator[location] = subdivision.volume
          }
        }
      }
    
      for (location, volume) in locationVolumes {
        let exactLocation: Double = Double(self.audioBuffer!.pointee.mAudioDataByteSize / sizeOfFloat) * Double(location)
        let startFrame: Int = Int((exactLocation / Double(sizeOfFloat)).rounded()) * Int(sizeOfFloat)
      
        for (index, sample) in subdivisionAudio.enumerated() {
          buffer[startFrame + index] += sample * volume
        }
      }
    }
  }
}
