let locationPrecision: Float = 2

class Subdivision {
  var option: Int
  var volume: Float
  
  init(_ option: Int, _  volume: Float) {
    self.option = option
    self.volume = volume
  }
  
  func getLocations() -> [Float] {
    var startFrames: [Float] = Array(repeating: 1.0, count: self.option - 1)
      
    for (index, startFrame) in startFrames.enumerated() {
      let fullLocation: Float = startFrame / Float(self.option) * Float(index + 1)
      startFrames[index] = (fullLocation * pow(10, locationPrecision)).rounded() / pow(10, locationPrecision)
    }
      
    return startFrames
  }
}
