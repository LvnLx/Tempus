import Foundation

class Subdivision: CustomStringConvertible {
  var option: Int
  var volume: Float
  var locations: [UnsafeMutableRawPointer]
  
  init(option: Int, volume: Float) {
    self.option = option
    self.volume = volume
    self.locations = []
  }
  
  var description: String {
    return "Subdivision(option: \(self.option), volume: \(self.volume)"
  }
  
  func setOption(option: Int) {
    self.option = option
  }
  
  func setVolume(volume: Float) {
    self.volume = volume
  }
}
