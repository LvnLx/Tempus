import AVFoundation

class Metronome {
  private var audioUnit: AudioUnit?
  private var buffer: MetronomeBuffer = MetronomeBuffer(sampleRate * 60)
  private var subdivisions: [String: Subdivision] = [:]
  private var volume: Float?

  init() {
    initializeBuffer()
    setupAudioUnit()
    setupBufferCallbacks()
  }
  
  func addSubdivision(_ key: String, _ option: Int, _ volume: Float) {
    subdivisions[key] = Subdivision(option, volume)
    writeBuffer()
  }
  
  func removeSubdivision(_ key: String) {
    subdivisions.removeValue(forKey: key)
    writeBuffer()
  }
  
  func setBpm(_ bpm: UInt16) {
    let bps: Double = Double(bpm) / 60.0
    let beatDurationSeconds: Double = 1.0 / bps
    buffer.validFrames.pointee = Int(beatDurationSeconds * Double(sampleRate))
    
    writeBuffer()
  }
  
  func setSubdivisionOption(_ key: String, _ option: Int) {
    subdivisions[key]!.option = option
    writeBuffer()
  }
  
  func setSubdivisionVolume(_ key: String, _ volume: Float) {
    subdivisions[key]!.volume = volume
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
  
  private func initializeBuffer() {
    let bps: Double = 120 / 60
    let beatDurationSeconds: Double = 1.0 / bps
    buffer.validFrames.pointee = Int(beatDurationSeconds * Double(sampleRate))
    
    writeBuffer()
  }
  
  private func setupAudioUnit() {
    var audioComponentDescription: AudioComponentDescription = AudioComponentDescription(
      componentType: kAudioUnitType_Output,
      componentSubType: kAudioUnitSubType_RemoteIO,
      componentManufacturer: kAudioUnitManufacturer_Apple,
      componentFlags: 0,
      componentFlagsMask: 0
    )
    
    let audioComponent: AudioComponent? = AudioComponentFindNext(nil, &audioComponentDescription)
    guard AudioComponentInstanceNew(audioComponent!, &audioUnit) == noErr else {
      print("Error creating new audio component instance")
      return
    }
    
    guard AudioUnitSetProperty(
      audioUnit!,
      kAudioUnitProperty_StreamFormat,
      kAudioUnitScope_Input,
      0,
      &audioStreamBasicDescription,
      UInt32(MemoryLayout.size(ofValue: audioStreamBasicDescription))
    ) == noErr else {
      print("Error setting stream format property")
      return
    }
    
    let auRenderCallback: AURenderCallback = { inRefCon, _, _, _, inNumberFrames, ioData in
      let inRefCon = inRefCon.assumingMemoryBound(to: RefCon.self).pointee
      
      let nextFrameToCopy = inRefCon.nextFrameToCopy.pointee
      let sourceFrames = inRefCon.sourceFrames
      let validFrames = inRefCon.validFrames.pointee
      
      let targetFrames = ioData!.pointee.mBuffers.mData!.assumingMemoryBound(to: Float.self)
      
      for i in 0..<inNumberFrames {
        if (nextFrameToCopy + Int(i) >= validFrames) {
          inRefCon.nextFrameToCopy.pointee = 0
        }
        
        targetFrames.advanced(by: Int(i)).pointee = sourceFrames.advanced(by: nextFrameToCopy + Int(i)).pointee
        
        inRefCon.nextFrameToCopy.pointee += 1
      }
      
      return noErr
    }
    
    let refCon = UnsafeMutableRawPointer.allocate(byteCount: MemoryLayout<RefCon>.size, alignment: MemoryLayout<RefCon>.alignment)
    let nextFrameToCopy = UnsafeMutablePointer<Int>.allocate(capacity: MemoryLayout<Int>.size)
    nextFrameToCopy.pointee = 0
    refCon.storeBytes(of: RefCon(nextFrameToCopy: nextFrameToCopy, sourceFrames: buffer.frames, validFrames: buffer.validFrames), as: RefCon.self)
    var auRenderCallbackStruct: AURenderCallbackStruct = AURenderCallbackStruct(
      inputProc: auRenderCallback,
      inputProcRefCon: refCon
    )
    
    guard AudioUnitSetProperty(
      audioUnit!,
      kAudioUnitProperty_SetRenderCallback,
      kAudioUnitScope_Global,
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
  
  private func setupBufferCallbacks() {
    buffer.callbacks.append { buffer in
      for (index, sample) in audioData["downbeat"]!.enumerated() {
        buffer[index] += sample * self.volume!
      }
    }
    
    buffer.callbacks.append { (buffer: inout [Float]) in
      let locationVolumes: [Float:Float] = self.subdivisions.values.reduce(into: [:]) {(accumulator, subdivision) in
        for location in subdivision.getLocations() {
          if (subdivision.volume >= accumulator[location] ?? 0) {
            accumulator[location] = subdivision.volume
          }
        }
      }
    
      for (location, volume) in locationVolumes {
        let exactLocation: Double = Double(buffer.count) * Double(location)
        let startFrame: Int = Int((exactLocation / Double(sizeOfFloat)).rounded()) * Int(sizeOfFloat)
      
        for (index, sample) in audioData["subdivision"]!.enumerated() {
          if (startFrame + index < buffer.count) {
            buffer[startFrame + index] += sample * volume * self.volume!
          }
        }
      }
    }
  }
  
  private func writeBuffer() {
    var updatedBuffer: [Float] = Array(repeating: 0, count: buffer.validFrames.pointee)
    for callback in buffer.callbacks {
      callback(&updatedBuffer)
    }
    
    buffer.frames.update(from: updatedBuffer, count: buffer.validFrames.pointee)
  }
}

struct RefCon {
  var nextFrameToCopy: UnsafeMutablePointer<Int>
  var sourceFrames: UnsafePointer<Float>
  var validFrames: UnsafePointer<Int>
}
