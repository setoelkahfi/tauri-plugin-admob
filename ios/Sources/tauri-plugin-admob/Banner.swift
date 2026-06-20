import Foundation
import Tauri
import UIKit
import GoogleMobileAds

/// Banner ad, mirroring the Android `ads.Banner` implementation. The banner is
/// pinned to the top or bottom of the root view controller's view.
class Banner: AdBase, BannerViewDelegate {
  private var bannerView: BannerView?
  private let position: String

  init(id: Int, adUnitId: String, plugin: AdmobPlugin, position: String) {
    self.position = position
    super.init(id: id, adUnitId: adUnitId, plugin: plugin)
  }

  override var isLoaded: Bool { bannerView != nil }

  override func load(args: InvokeArgs, request: Request, invoke: Invoke) {
    if bannerView == nil {
      let width = UIScreen.main.bounds.width
      let bannerView = BannerView(
        adSize: currentOrientationAnchoredAdaptiveBanner(width: width))
      bannerView.adUnitID = adUnitId
      bannerView.rootViewController = plugin?.topViewController
      bannerView.delegate = self
      self.bannerView = bannerView
    }
    bannerView?.load(request)
    invoke.resolve()
  }

  override func show(invoke: Invoke) {
    guard let bannerView = bannerView, let plugin = plugin else {
      invoke.reject("banner ad is not loaded")
      return
    }
    plugin.attachBanner(bannerView, top: position == "top")
    bannerView.isHidden = false
    invoke.resolve()
  }

  override func hide(invoke: Invoke) {
    bannerView?.isHidden = true
    invoke.resolve()
  }

  override func destroy() {
    bannerView?.removeFromSuperview()
    bannerView = nil
  }

  // MARK: - BannerViewDelegate

  func bannerViewDidReceiveAd(_ bannerView: BannerView) {
    emit(Events.bannerLoad)
  }

  func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
    emit(Events.bannerLoadFail, error: error)
  }

  func bannerViewDidRecordImpression(_ bannerView: BannerView) {
    emit(Events.bannerImpression)
  }

  func bannerViewDidRecordClick(_ bannerView: BannerView) {
    emit(Events.bannerClick)
  }

  func bannerViewWillPresentScreen(_ bannerView: BannerView) {
    emit(Events.bannerOpen)
  }

  func bannerViewDidDismissScreen(_ bannerView: BannerView) {
    emit(Events.bannerClose)
  }
}
