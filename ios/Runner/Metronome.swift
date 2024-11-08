import AVFoundation

let sizeOfFloat: UInt32 = UInt32(MemoryLayout<Float>.size)
let sampleRate: Float64 = 44100.0

class Metronome {
  private var audioUnit: AudioUnit?
  
  private var bufferCallbacks: [(_ buffer: inout [Float]) -> Void] = []
  private var subdivisions: [String: Subdivision] = [:]
  private var volume: Float = 1

  init() {
    var audioComponentDescription: AudioComponentDescription = AudioComponentDescription(
      componentType: kAudioUnitType_Output,
      componentSubType: kAudioUnitSubType_GenericOutput,
      componentManufacturer: kAudioUnitManufacturer_Apple,
      componentFlags: 0,
      componentFlagsMask: 0
    )
    
    let audioComponent: AudioComponent? = AudioComponentFindNext(nil, &audioComponentDescription)
    guard AudioComponentInstanceNew(audioComponent!, &audioUnit) == noErr else {
      print("Error creating new audio component instance")
      return
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
    guard AudioUnitSetProperty(
      audioUnit!,
      kAudioUnitProperty_StreamFormat,
      kAudioUnitScope_Output,
      0,
      &audioStreamBasicDescription,
      UInt32(MemoryLayout.size(ofValue: audioStreamBasicDescription))
    ) == noErr else {
      print("Error setting stream format property")
      return
    }
    
    let auRenderCallback: AURenderCallback = { _, _, _, _, inNumberFrames, ioData in
      print("Hi")
      return noErr
    }
    var auRenderCallbackStruct: AURenderCallbackStruct = AURenderCallbackStruct(inputProc: auRenderCallback, inputProcRefCon: nil)
    
    guard AudioUnitSetProperty(
      audioUnit!,
      kAudioUnitProperty_SetRenderCallback,
      kAudioUnitScope_Input,
      0,
      &auRenderCallbackStruct,
      UInt32(MemoryLayout.size(ofValue: auRenderCallbackStruct))
    ) == noErr else {
      print("Error setting render callback property")
      return
    }
    
    guard AudioUnitInitialize(audioUnit!) == noErr else {
      print("Error initializing audio unit")
      return
    }
  }
  
  func addSubdivision(_ key: String, _ option: Int, _ volume: Float) {
    let subdivision = Subdivision(option, volume)
    subdivisions[key] = subdivision
    
    writeBuffer()
  }
  
  func removeSubdivision(_ key: String) {
    subdivisions.removeValue(forKey: key)

    writeBuffer()
  }
  
  func setBpm(_ bpm: UInt16) {
    let bps: Double = Double(bpm) / 60.0
    let beatDurationSeconds: Double = 1.0 / bps
    // audioBuffer!.pointee.mAudioDataByteSize = UInt32(beatDurationSeconds * sampleRate * Double(sizeOfFloat))
    
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
    self.volume = volume
    
    writeBuffer()
  }
  
  func startPlayback() {
    guard AudioOutputUnitStart(audioUnit!) == noErr else {
      print("Error starting audio output unit")
      return
    }
  }
  
  func stopPlayback() {
    guard AudioOutputUnitStop(audioUnit!) == noErr else {
      print("Error stopping audio output unit")
      return
    }
  }
  
  func writeBuffer() {
    // var buffer: [Float] = Array(repeating: 0, count: Int(audioBuffer!.pointee.mAudioDataByteSize) / Int(sizeOfFloat))
    
    /*
    for bufferCallback in bufferCallbacks {
      bufferCallback(&buffer)
    }
    */
    
    // audioBuffer!.pointee.mAudioData.copyMemory(from: buffer, byteCount: buffer.count * Int(sizeOfFloat))
  }
  
  private func createBufferCallbacks() {
    bufferCallbacks.append { buffer in
      for (index, sample) in downbeatAudio.enumerated() {
        buffer[index] += sample * self.volume
      }
    }
    
    bufferCallbacks.append { buffer in
      let locationVolumes: [Float:Float] = self.subdivisions.values.reduce(into: [:]) {(accumulator, subdivision) in
        for location in subdivision.getLocations() {
          if (subdivision.volume >= accumulator[location] ?? 0) {
            accumulator[location] = subdivision.volume
          }
        }
      }
    
      for (location, volume) in locationVolumes {
        // let exactLocation: Double = Double(self.audioBuffer!.pointee.mAudioDataByteSize / sizeOfFloat) * Double(location)
        // let startFrame: Int = Int((exactLocation / Double(sizeOfFloat)).rounded()) * Int(sizeOfFloat)
      
        /*
        for (index, sample) in subdivisionAudio.enumerated() {
          buffer[startFrame + index] += sample * volume * self.volume
        }
        */
      }
    }
  }
}
