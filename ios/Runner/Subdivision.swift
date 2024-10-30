import Foundation

class Subdivision: CustomStringConvertible {
  var option: Int
  var volume: Float
  var locations: [Double]
  
  init(option: Int, volume: Float) {
    self.option = option
    self.volume = volume
    self.locations = Subdivision.getStartFrames(option: self.option)
  }
  
  var description: String {
    return "Subdivision(option: \(self.option), volume: \(self.volume), startFrames: \(self.locations))"
  }
  
  func setOption(option: Int, bufferSize: UInt32) {
    self.option = option
    self.locations = Subdivision.getStartFrames(option: self.option)
  }
  
  func setVolume(volume: Float) {
    self.volume = volume
  }
  
  private static func getStartFrames(option: Int) -> [Double] {
    var startFrames = Array(repeating: 1.0, count: option - 1)
      
    for (index, startFrame) in startFrames.enumerated() {
      startFrames[index] = (startFrame / Double(option) * Double(index + 1) * 100).rounded() / 100
    }
      
    return startFrames
  }
}
