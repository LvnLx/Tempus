let sizeOfFloat: Int = MemoryLayout<Float>.size
let sampleRate: Int = 44100
var audioStreamBasicDescription: AudioStreamBasicDescription = AudioStreamBasicDescription(
  mSampleRate: Double(sampleRate),
  mFormatID: kAudioFormatLinearPCM,
  mFormatFlags: kLinearPCMFormatFlagIsFloat | kLinearPCMFormatFlagIsPacked,
  mBytesPerPacket: UInt32(sizeOfFloat),
  mFramesPerPacket: 1,
  mBytesPerFrame: UInt32(sizeOfFloat),
  mChannelsPerFrame: 1,
  mBitsPerChannel: UInt32(sizeOfFloat) * 8,
  mReserved: 0
)
