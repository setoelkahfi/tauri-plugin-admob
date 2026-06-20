import Foundation
import GoogleMobileAds

/// Decoded representation of the arguments sent from JS for every command.
/// Mirrors the Android `InvokeArgs`/`ServerSideVerification` classes.
struct ServerSideVerificationArgs: Decodable {
  var userId: String?
  var customData: String?
}

struct InvokeArgs: Decodable {
  var cls: String?
  var id: Int?
  var adUnitId: String?
  var appMuted: Bool?
  var appVolume: Float?
  var position: String?
  var contentUrl: String?
  var npa: String?
  var maxAdContentRating: String?
  var tagForChildDirectedTreatment: Bool?
  var tagForUnderAgeOfConsent: Bool?
  var testDeviceIds: [String]?
  var serverSideVerification: ServerSideVerificationArgs?
  var customData: String?
  var userId: String?
}

extension InvokeArgs {
  /// Builds an ad `Request` from the optional `contentUrl`/`npa` arguments,
  /// matching `Context.optAdRequest()` on Android.
  func buildRequest() -> Request {
    let request = Request()
    if let contentUrl = contentUrl {
      request.contentURL = contentUrl
    }
    if let npa = npa {
      let extras = Extras()
      extras.additionalParameters = ["npa": npa]
      request.register(extras)
    }
    return request
  }

  /// Server side verification options for rewarded ads, or nil when not provided.
  func buildServerSideVerificationOptions() -> ServerSideVerificationOptions? {
    guard let ssv = serverSideVerification else { return nil }
    let options = ServerSideVerificationOptions()
    if let userId = ssv.userId {
      options.userIdentifier = userId
    }
    if let customData = ssv.customData {
      options.customRewardString = customData
    }
    return options
  }

  /// Applies the request configuration arguments to the global `MobileAds`
  /// request configuration, matching `Context.optRequestConfiguration()`.
  func applyRequestConfiguration() {
    let config = MobileAds.shared.requestConfiguration
    if let rating = maxAdContentRating {
      config.maxAdContentRating = MaxAdContentRating(rawValue: rating)
    }
    if let child = tagForChildDirectedTreatment {
      config.tagForChildDirectedTreatment = NSNumber(value: child)
    }
    if let underAge = tagForUnderAgeOfConsent {
      config.tagForUnderAgeOfConsent = NSNumber(value: underAge)
    }
    if let ids = testDeviceIds {
      config.testDeviceIdentifiers = ids
    }
  }
}
