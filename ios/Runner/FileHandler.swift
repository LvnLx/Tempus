import AudioToolbox

var samples: [String:UnsafePointer<Sample>] = [:]

func loadAudioFile(_ path: String, _ key: String) {
  let url: URL = URL(string: Bundle.main.path(forResource: key, ofType: nil)!)!
  
  var audioFile: AudioFileID? = nil
  var status: OSStatus = AudioFileOpenURL(url as CFURL, .readPermission, kAudioFileWAVEType, &audioFile)
  if status != noErr {
    print("Failed to open audio file")
  }
  
  var propertySize: UInt32 = UInt32()
  var propertyWritable: UInt32 = UInt32()
  status = AudioFileGetPropertyInfo(audioFile!, kAudioFilePropertyAudioDataByteCount, &propertySize, &propertyWritable)
  if status != noErr {
    print("Failed to get audio file size property")
  }
  
  var fileSize: UInt32 = UInt32()
  status = AudioFileGetProperty(audioFile!, kAudioFilePropertyAudioDataByteCount, &propertySize, &fileSize)
  if status != noErr {
    print("Failed to get audio file size")
  }
  
  var buffer: [Float] = [Float](repeating: 0.0, count: Int(fileSize) / sizeOfFloat)
  
  status = AudioFileReadBytes(audioFile!, true, 0, &fileSize, &buffer)
  if status != noErr {
    print("Failed to read audio file")
  }
  
  let sample = UnsafeMutablePointer<Sample>.allocate(capacity: 1)
  sample.pointee.data = UnsafeMutablePointer<Float>.allocate(capacity: buffer.count)
  sample.pointee.data.update(from: buffer, count: buffer.count)
  sample.pointee.length = buffer.count

  samples[path] = UnsafePointer(sample)
}

