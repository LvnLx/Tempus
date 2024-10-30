import Foundation


class Subdivision: CustomStringConvertible {
  static let locationPrecision: Double = 8

  var option: Int
  var volume: Float
  var locations: [Double]
  
  init(_ option: Int, _  volume: Float) {
    self.option = option
    self.volume = volume
    self.locations = Subdivision.getLocations(option: self.option)
  }
  
  var description: String {
    return "Subdivision(option: \(self.option), volume: \(self.volume), startFrames: \(self.locations))"
  }
  
  func setOption(option: Int) {
    self.option = option
    self.locations = Subdivision.getLocations(option: self.option)
  }
  
  func setVolume(volume: Float) {
    self.volume = volume
  }
  
  private static func getLocations(option: Int) -> [Double] {
    var startFrames = Array(repeating: 1.0, count: option - 1)
      
    for (index, startFrame) in startFrames.enumerated() {
      let fullLocation = startFrame / Double(option) * Double(index + 1)
      startFrames[index] = (fullLocation * pow(10, locationPrecision)).rounded() / pow(10, locationPrecision)
    }
      
    return startFrames
  }
}
