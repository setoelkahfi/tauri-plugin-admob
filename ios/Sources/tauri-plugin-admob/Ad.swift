import Foundation
import Tauri
import GoogleMobileAds

/// Base class shared by every ad type. Holds the identity of the ad and a weak
/// reference to the owning plugin used to emit events. Mirrors the Android
/// `core.Ad` / `ads.AdBase` hierarchy.
class AdBase: NSObject {
  let id: Int
  let adUnitId: String
  weak var plugin: AdmobPlugin?

  init(id: Int, adUnitId: String, plugin: AdmobPlugin) {
    self.id = id
    self.adUnitId = adUnitId
    self.plugin = plugin
    super.init()
  }

  /// Whether the ad has been loaded and is ready to be shown.
  var isLoaded: Bool { false }

  func load(args: InvokeArgs, request: Request, invoke: Invoke) {
    invoke.reject("Not implemented")
  }

  func show(invoke: Invoke) {
    invoke.reject("Not implemented")
  }

  func hide(invoke: Invoke) {
    invoke.reject("Not implemented")
  }

  func destroy() {}

  // MARK: - Event helpers

  /// Emits an event with the given payload, always including the `adId` so JS
  /// listeners can correlate the event with the originating ad instance.
  func emit(_ event: String, _ data: JSObject = [:]) {
    var payload = data
    payload["adId"] = id
    plugin?.trigger(event, data: payload)
  }

  /// Emits an event carrying error information, mirroring the Android
  /// `emit(eventName, AdError)` overload.
  func emit(_ event: String, error: Error) {
    let nsError = error as NSError
    emit(event, [
      "code": nsError.code,
      "message": nsError.localizedDescription,
      "cause": nsError.domain,
    ])
  }

  /// Emits a reward event, mirroring the Android `emit(eventName, RewardItem)` overload.
  func emit(_ event: String, reward: AdReward) {
    emit(event, [
      "reward": [
        "amount": reward.amount.doubleValue,
        "type": reward.type,
      ] as JSObject
    ])
  }
}
