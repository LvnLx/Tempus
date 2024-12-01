struct RefCon {
  let dispatchQueue: UnsafeMutablePointer<DispatchQueue>
  let nextFrame: UnsafeMutablePointer<Int>
  let validFrameCount: UnsafePointer<Int>
}
