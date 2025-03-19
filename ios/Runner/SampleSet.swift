class SampleSet {
  let beatSample: UnsafePointer<Sample>
  let downbeatSample: UnsafePointer<Sample>
  let innerBeatSample: UnsafePointer<Sample>
  
  init(_ sampleSetAsJsonString: String) {
    let sampleSetAsData: Data? = sampleSetAsJsonString.data(using: .utf8)
    let sampleSetAsJson: [String: String] = try! JSONSerialization.jsonObject(with: sampleSetAsData!) as! [String: String]
    
    beatSample = samples[sampleSetAsJson["beatSamplePath"]!]!
    downbeatSample = samples[sampleSetAsJson["downbeatSamplePath"]!]!
    innerBeatSample = samples[sampleSetAsJson["innerBeatSamplePath"]!]!
  }
}
