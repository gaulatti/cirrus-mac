import Foundation

func isTokenExpired(_ token: String) -> Bool {
    let parts = token.split(separator: ".")
    guard parts.count == 3 else { return true }
    let payloadPart = String(parts[1])
    
    // Add padding if necessary
    var base64 = payloadPart
    let remainder = base64.count % 4
    if remainder > 0 {
        base64 += String(repeating: "=", count: 4 - remainder)
    }
    
    guard let payloadData = Data(base64Encoded: base64),
          let payloadJson = try? JSONSerialization.jsonObject(with: payloadData, options: []),
          let payload = payloadJson as? [String: Any],
          let exp = payload["exp"] as? TimeInterval
    else {
        return true
    }
    
    let expDate = Date(timeIntervalSince1970: exp)
    return Date() >= expDate
}
