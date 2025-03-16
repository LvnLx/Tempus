class Fraction {
  var numerator: UInt16
  var denominator: UInt16
  
  init(_ fractionAsJsonString: String) {
    let fractionAsData: Data? = fractionAsJsonString.data(using: .utf8)
    let fractionAsJson: [String: UInt16] = try! JSONSerialization.jsonObject(with: fractionAsData!) as! [String: UInt16]
    
    numerator = fractionAsJson["numerator"]!
    denominator = fractionAsJson["denominator"]!
  }
}

class BeatUnit: Fraction {}

class TimeSignature: Fraction {}
