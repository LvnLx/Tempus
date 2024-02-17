import Foundation

class Subdivision: CustomStringConvertible {
  var option: Int
  var volume: Float
  
  init(option: Int) {
    self.option = option
    self.volume = 0.0
  }
  
  var description: String {
    return "Subdivision(option: \(self.option), volume: \(self.volume)"
  }
}
