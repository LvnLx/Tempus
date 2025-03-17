class Fraction {
  var numerator: UInt16
  var denominator: UInt16
  
  init(_ fractionAsJsonString: String) {
    let fractionAsData: Data? = fractionAsJsonString.data(using: .utf8)
    let fractionAsJson: [String: UInt16] = try! JSONSerialization.jsonObject(with: fractionAsData!) as! [String: UInt16]
    
    numerator = fractionAsJson["numerator"]!
    denominator = fractionAsJson["denominator"]!
  }
  
  init(_ numerator: UInt16, _ denominator: UInt16) {
    self.numerator = numerator
    self.denominator = denominator
  }
  
  static func / (left: Fraction, right: Fraction) -> Fraction {
    return Fraction(left.numerator * right.denominator, left.denominator * right.numerator)
  }
  
  func evaluate() -> Double {
    Double(numerator) / Double(denominator)
  }
}

class BeatUnit: Fraction {}

class TimeSignature: Fraction {}
