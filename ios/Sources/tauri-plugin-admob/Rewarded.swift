import Foundation
import Tauri
import GoogleMobileAds

/// Rewarded ad, mirroring the Android `ads.Rewarded` implementation.
class Rewarded: AdBase, FullScreenContentDelegate {
  private var ad: RewardedAd?

  override var isLoaded: Bool { ad != nil }

  override func load(args: InvokeArgs, request: Request, invoke: Invoke) {
    clear()
    RewardedAd.load(with: adUnitId, request: request) { [weak self] ad, error in
      guard let self = self else { return }
      if let error = error {
        self.clear()
        self.emit(Events.rewardedLoadFail, error: error)
        invoke.reject(error.localizedDescription)
        return
      }
      self.ad = ad
      if let ssv = args.buildServerSideVerificationOptions() {
        ad?.serverSideVerificationOptions = ssv
      }
      ad?.fullScreenContentDelegate = self
      self.emit(Events.rewardedLoad)
      invoke.resolve()
    }
  }

  override func show(invoke: Invoke) {
    guard let ad = ad, let vc = plugin?.topViewController else {
      invoke.reject("rewarded ad is not loaded")
      return
    }
    ad.present(from: vc) { [weak self, weak ad] in
      guard let self = self, let ad = ad else { return }
      self.emit(Events.rewardedReward, reward: ad.adReward)
    }
    invoke.resolve()
  }

  override func destroy() {
    clear()
  }

  private func clear() {
    ad?.fullScreenContentDelegate = nil
    ad = nil
  }

  // MARK: - FullScreenContentDelegate

  func adDidRecordImpression(_ ad: FullScreenPresentingAd) {
    emit(Events.rewardedImpression)
  }

  func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
    emit(Events.rewardedShow)
  }

  func ad(
    _ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error
  ) {
    emit(Events.rewardedShowFail, error: error)
  }

  func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
    clear()
    emit(Events.rewardedDismiss)
  }
}
