import Foundation
import Tauri
import GoogleMobileAds

/// Interstitial ad, mirroring the Android `ads.Interstitial` implementation.
class Interstitial: AdBase, FullScreenContentDelegate {
  private var ad: InterstitialAd?

  override var isLoaded: Bool { ad != nil }

  override func load(args: InvokeArgs, request: Request, invoke: Invoke) {
    clear()
    InterstitialAd.load(with: adUnitId, request: request) { [weak self] ad, error in
      guard let self = self else { return }
      if let error = error {
        self.clear()
        self.emit(Events.interstitialLoadFail, error: error)
        invoke.reject(error.localizedDescription)
        return
      }
      self.ad = ad
      ad?.fullScreenContentDelegate = self
      self.emit(Events.interstitialLoad)
      invoke.resolve()
    }
  }

  override func show(invoke: Invoke) {
    guard let ad = ad, let vc = plugin?.topViewController else {
      invoke.reject("interstitial ad is not loaded")
      return
    }
    ad.present(from: vc)
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
    emit(Events.interstitialImpression)
  }

  func adWillPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
    emit(Events.interstitialShow)
  }

  func ad(
    _ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error
  ) {
    emit(Events.interstitialShowFail, error: error)
  }

  func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
    clear()
    emit(Events.interstitialDismiss)
  }
}
