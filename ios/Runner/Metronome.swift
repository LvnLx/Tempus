import AVFoundation

class Metronome {
  private var appVolume: Float?
  private var audioUnit: AudioUnit?
  private var beatUnit: BeatUnit?
  private var beatVolume: Float?
  private var bpm: UInt16?
  private var downbeatVolume: Float?
  private var dispatchQueue: UnsafeMutablePointer<DispatchQueue> = UnsafeMutablePointer<DispatchQueue>.allocate(capacity: 1)
  private let nextFrame: UnsafeMutablePointer<Int> = UnsafeMutablePointer.allocate(capacity: 1)
  private var subdivisions: [String: Subdivision]?
  private let beatStarted: () -> Void
  private var sampleSet: SampleSet?
  private var timeSignature: TimeSignature?
  private let validFrameCount: UnsafeMutablePointer<Int> = UnsafeMutablePointer<Int>.allocate(capacity: 1)
  
  init(_ beatStarted: @escaping () -> Void) {
    self.beatStarted = beatStarted
    dispatchQueue.initialize(to: DispatchQueue(label: "com.lvnlx.tempus"))
    
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
      let inNumberFrames = Int(inNumberFrames)
      let ioData = ioData!.pointee.mBuffers.mData!.assumingMemoryBound(to: Float.self)
      
      let dispatchQueue = inRefCon.dispatchQueue
      let validFrameCount = inRefCon.validFrameCount.pointee
      
      dispatchQueue.pointee.sync {
        for index in 0..<inNumberFrames {
          inRefCon.nextFrame.pointee = inRefCon.nextFrame.pointee % validFrameCount
          
          ioData.advanced(by: index).pointee = 0
          
          for clip in clips {
            if (clip.pointee.isActive && !clip.pointee.isPlaying && clip.pointee.startFrame == inRefCon.nextFrame.pointee) {
              clip.pointee.isPlaying = true
              clip.pointee.onStart()
            }
            
            if (clip.pointee.isPlaying) {
              if (clip.pointee.nextFrame < clip.pointee.sample.pointee.length) {
                ioData.advanced(by: index).pointee += clip.pointee.sample.pointee.data.advanced(by: clip.pointee.nextFrame).pointee * clip.pointee.volume
                clip.pointee.nextFrame += 1
              } else {
                clip.pointee.isPlaying = false
                clip.pointee.nextFrame = 0
              }
            }
          }
          
          inRefCon.nextFrame.pointee += 1
        }
      }
      
      return noErr
    }
    
    nextFrame.pointee = 0
    let refCon = UnsafeMutableRawPointer.allocate(byteCount: MemoryLayout<RefCon>.size, alignment: MemoryLayout<RefCon>.alignment)
    refCon.storeBytes(of: RefCon(dispatchQueue: dispatchQueue, nextFrame: nextFrame, validFrameCount: validFrameCount), as: RefCon.self)
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
  
  func setAppVolume(_ volume: Float, _ shouldUpdateClips: Bool = true) {
    appVolume = volume
    if (shouldUpdateClips) {
      updateClips()
    }
  }
  
  func setBeatUnit(_ beatUnit: BeatUnit, _ shouldUpdateClips: Bool = true, _ shouldUpdatedValidFrameCount: Bool = true) {
    self.beatUnit = beatUnit
    
    if (shouldUpdatedValidFrameCount) {
      updateValidFrameCount()
    }
    
    if (shouldUpdateClips) {
      updateClips()
    }
  }
  
  func setBeatVolume(_ volume: Float, _ shouldUpdateClips: Bool = true) {
    beatVolume = volume
    if (shouldUpdateClips) {
      updateClips()
    }
  }
  
  func setBpm(_ bpm: UInt16, _ shouldUpdateClips: Bool = true, _ shouldUpdatedValidFrameCount: Bool = true) {
    self.bpm = bpm
    
    if (shouldUpdatedValidFrameCount) {
      updateValidFrameCount()
    }
    
    if (shouldUpdateClips) {
      updateClips()
    }
  }
  
  func setDownbeatVolume(_ volume: Float, _ shouldUpdateClips: Bool = true) {
    downbeatVolume = volume
    if (shouldUpdateClips) {
      updateClips()
    }
  }
  
  func setSampleSet(_ sampleSet: SampleSet, _ shouldUpdateClips: Bool = true) {
    self.sampleSet = sampleSet
    if (shouldUpdateClips) {
      updateClips()
    }
  }
  
  func setSubdivisions(_ subdivisions: [String: Subdivision], _ shouldUpdateClips: Bool = true) {
    self.subdivisions = subdivisions
    if (shouldUpdateClips) {
      updateClips()
    }
  }
  
  func setTimeSignature(_ timeSignature: TimeSignature, _ shouldUpdateClips: Bool = true, _ shouldUpdateValidFrameCount: Bool = true) {
    self.timeSignature = timeSignature
    
    if (shouldUpdateValidFrameCount) {
      updateValidFrameCount()
    }
    
    if (shouldUpdateClips) {
      updateClips()
    }
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
    
    nextFrame.pointee = 0
    for clip in clips {
      clip.pointee.isPlaying = false
      clip.pointee.nextFrame = 0
    }
  }
  
  func updateClips() {
    let downbeatClip: UnsafeMutablePointer<Clip> = UnsafeMutablePointer<Clip>.allocate(capacity: 1)
    downbeatClip.initialize(to: Clip(sample: sampleSet!.downbeatSample, startFrame: 0, volume: downbeatVolume! * appVolume! * 1.5))
    
    let beatCount: Double = (timeSignature! / beatUnit!).evaluate()
    let beatLength: Int = Int((Double(validFrameCount.pointee) / beatCount).rounded())

    var beatClips: [UnsafeMutablePointer<Clip>] = []
    var subdivisionClips: [UnsafeMutablePointer<Clip>] = []
    let subdivisionClipData: [(Int, Float)] = subdivisions!.values
      .reduce(into: [Float:Float]()) { (accumulator, subdivision) in
        for location in subdivision.getLocations() {
          if (subdivision.volume >= accumulator[location] ?? 0) {
            accumulator[location] = subdivision.volume
          }
        }
      }
      .map { (location, volume) in
        let exactLocation: Double = Double(beatLength) * Double(location)
        return (Int((exactLocation / Double(sizeOfFloat)).rounded()) * Int(sizeOfFloat), volume)
      }
    
    (0..<Int(ceil(beatCount))).forEach { (beat) in
      let beatClip: UnsafeMutablePointer<Clip> = UnsafeMutablePointer<Clip>.allocate(capacity: 1)
      beatClip.initialize(to: Clip(onStart: beatStarted, sample: sampleSet!.beatSample, startFrame: beat * beatLength, volume: beatVolume! * appVolume!))
      beatClips.append(beatClip)
      
      subdivisionClipData.forEach { (startFrame, volume) in
        let subdivisionClip: UnsafeMutablePointer<Clip> = UnsafeMutablePointer<Clip>.allocate(capacity: 1)
        subdivisionClip.initialize(to: Clip(sample: sampleSet!.innerBeatSample, startFrame: (beat * beatLength) + startFrame, volume: volume * appVolume!))
        subdivisionClips.append(subdivisionClip)
      }
    }
    
    dispatchQueue.pointee.async {
      clips = clips.filter { $0.pointee.isPlaying }
      for index in clips.indices { clips[index].pointee.isActive = false }
      
      clips.append(downbeatClip)
      clips.append(contentsOf: beatClips)
      clips.append(contentsOf: subdivisionClips)
    }
  }
  
  func updateValidFrameCount(_ isSetState: Bool = false) {
    let bufferLocation = Double(nextFrame.pointee) / Double(validFrameCount.pointee)
    
    let bps: Double = Double(bpm!) / 60.0
    let beatDurationSeconds: Double = 1.0 / bps
    
    let beatCount: Double = (timeSignature! / beatUnit!).evaluate()
    
    self.validFrameCount.pointee = Int(beatDurationSeconds * beatCount * Double(sampleRate))
    
    if (!isSetState) {
      self.nextFrame.pointee = Int(round(Double(self.validFrameCount.pointee) * bufferLocation))
    }
  }
}
