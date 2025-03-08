var clips: [UnsafeMutablePointer<Clip>] = []

struct Clip {
  var isPlaying: Bool = false
  var isActive: Bool = true
  var nextFrame: Int = 0
  var onStart: () -> Void = {}
  let sample: UnsafePointer<Sample>
  let startFrame: Int
  let volume: Float
}
