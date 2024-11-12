class MetronomeBuffer {
  final let maxFrames: Int

  var frames: UnsafeMutablePointer<Float>
  var callbacks: [(_ buffer: inout [Float]) -> Void] = []
  var validFrames: UnsafeMutablePointer<Int>
  
  init(_ maxAudioFramesCount: Int) {
    self.maxFrames = maxAudioFramesCount
    self.frames = UnsafeMutablePointer<Float>.allocate(capacity: maxAudioFramesCount)
    self.validFrames = UnsafeMutablePointer<Int>.allocate(capacity: MemoryLayout<Int>.size)
  }
}
