import AudioToolbox

func loadAudioFile(fileName: String, outputBuffer: UnsafeMutableRawPointer) -> UInt32 {
  let path: String = Bundle.main.path(forResource: fileName, ofType: "wav")!
  let url: URL = URL(string: path)!
  
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
  
  var buffer: [Float] = [Float](repeating: 0.0, count: Int(fileSize))
  
  let bytesRead: UInt32 = fileSize
  status = AudioFileReadBytes(audioFile!, true, 0, &fileSize, &buffer)
  if status != noErr {
    print("Failed to read audio file")
  }
 
  outputBuffer.copyMemory(from: buffer, byteCount: Int(bytesRead))
  
  return bytesRead / UInt32(MemoryLayout<Float>.size)
}
