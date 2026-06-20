import AppTrackingTransparency
import GoogleMobileAds
import SwiftRs
import Tauri
import UIKit
import UserMessagingPlatform
import WebKit

class AdmobPlugin: Plugin {
  private var webView: WKWebView?
  private var ads: [Int: AdBase] = [:]
  private var bannerContainerConstraints: [NSLayoutConstraint] = []

  // MARK: - Lifecycle

  override func load(webview: WKWebView) {
    super.load(webview: webview)
    self.webView = webview

    MobileAds.shared.start(completionHandler: nil)

    let parameters = RequestParameters()
    ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { [weak self] error in
      if let error = error {
        NSLog("admob: consent info update failed: \(error.localizedDescription)")
        return
      }
      guard let vc = self?.topViewController else { return }
      ConsentForm.loadAndPresentIfRequired(from: vc) { formError in
        if let formError = formError {
          NSLog("admob: consent form failed: \(formError.localizedDescription)")
        }
      }
    }
  }

  // MARK: - Privacy / consent

  private var isPrivacyOptionsRequired: Bool {
    ConsentInformation.shared.privacyOptionsRequirementStatus == .required
  }

  @objc public func isPrivacyOptionsRequired(_ invoke: Invoke) {
    invoke.resolve(["isPrivacyOptionsRequired": isPrivacyOptionsRequired])
  }

  @objc public func showPrivacyOptionsForm(_ invoke: Invoke) {
    DispatchQueue.main.async { [weak self] in
      guard let vc = self?.topViewController else {
        invoke.reject("no view controller available")
        return
      }
      ConsentForm.presentPrivacyOptionsForm(from: vc) { error in
        if let error = error {
          invoke.reject(error.localizedDescription)
          return
        }
        invoke.resolve()
      }
    }
  }

  // MARK: - App Tracking Transparency

  @objc public func trackingAuthorizationStatus(_ invoke: Invoke) {
    if #available(iOS 14, *) {
      let status = ATTrackingManager.trackingAuthorizationStatus
      invoke.resolve(["status": status == .authorized])
    } else {
      invoke.resolve(["status": true])
    }
  }

  @objc public func requestTrackingAuthorization(_ invoke: Invoke) {
    if #available(iOS 14, *) {
      ATTrackingManager.requestTrackingAuthorization { status in
        invoke.resolve(["status": status == .authorized])
      }
    } else {
      invoke.resolve(["status": true])
    }
  }

  // MARK: - Configuration

  @objc public func configure(_ invoke: Invoke) throws {
    let args = try invoke.parseArgs(InvokeArgs.self)
    if let muted = args.appMuted {
      MobileAds.shared.isAppMuted = muted
    }
    if let volume = args.appVolume {
      MobileAds.shared.applicationVolume = volume
    }
    args.applyRequestConfiguration()
    invoke.resolve()
  }

  @objc public func configRequest(_ invoke: Invoke) throws {
    let args = try invoke.parseArgs(InvokeArgs.self)
    args.applyRequestConfiguration()
    invoke.resolve()
  }

  // MARK: - Ad lifecycle commands

  @objc public func adCreate(_ invoke: Invoke) throws {
    let args = try invoke.parseArgs(InvokeArgs.self)
    guard let id = args.id else {
      invoke.reject("ad id is missing")
      return
    }
    guard let cls = args.cls else {
      invoke.reject("ad cls is missing")
      return
    }
    guard let adUnitId = args.adUnitId else {
      invoke.reject("ad adUnitId is missing")
      return
    }

    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      let ad: AdBase
      switch cls {
      case "BannerAd":
        ad = Banner(
          id: id, adUnitId: adUnitId, plugin: self, position: args.position ?? "bottom")
      case "InterstitialAd":
        ad = Interstitial(id: id, adUnitId: adUnitId, plugin: self)
      case "RewardedAd":
        ad = Rewarded(id: id, adUnitId: adUnitId, plugin: self)
      case "RewardedInterstitialAd":
        ad = RewardedInterstitial(id: id, adUnitId: adUnitId, plugin: self)
      default:
        invoke.reject("ad cls is not supported: \(cls)")
        return
      }
      self.ads[id] = ad
      invoke.resolve()
    }
  }

  @objc public func adIsLoaded(_ invoke: Invoke) throws {
    let args = try invoke.parseArgs(InvokeArgs.self)
    DispatchQueue.main.async { [weak self] in
      guard let ad = self?.ad(for: args.id, invoke: invoke) else { return }
      invoke.resolve(["data": ad.isLoaded])
    }
  }

  @objc public func adLoad(_ invoke: Invoke) throws {
    let args = try invoke.parseArgs(InvokeArgs.self)
    DispatchQueue.main.async { [weak self] in
      guard let ad = self?.ad(for: args.id, invoke: invoke) else { return }
      ad.load(args: args, request: args.buildRequest(), invoke: invoke)
    }
  }

  @objc public func adShow(_ invoke: Invoke) throws {
    let args = try invoke.parseArgs(InvokeArgs.self)
    DispatchQueue.main.async { [weak self] in
      guard let ad = self?.ad(for: args.id, invoke: invoke) else { return }
      if ad.isLoaded {
        ad.show(invoke: invoke)
      } else {
        invoke.reject("ad is not loaded")
      }
    }
  }

  @objc public func adHide(_ invoke: Invoke) throws {
    let args = try invoke.parseArgs(InvokeArgs.self)
    DispatchQueue.main.async { [weak self] in
      guard let ad = self?.ad(for: args.id, invoke: invoke) else { return }
      ad.hide(invoke: invoke)
    }
  }

  // MARK: - Helpers

  private func ad(for id: Int?, invoke: Invoke) -> AdBase? {
    guard let id = id, let ad = ads[id] else {
      invoke.reject("Ad not found")
      return nil
    }
    return ad
  }

  /// Returns the top-most view controller, used to present full screen ads,
  /// consent forms and to host banner views.
  var topViewController: UIViewController? {
    let keyWindow =
      UIApplication.shared.connectedScenes
      .compactMap { $0 as? UIWindowScene }
      .flatMap { $0.windows }
      .first { $0.isKeyWindow }
    var top = keyWindow?.rootViewController
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }

  /// Attaches a banner view to the root view, pinned to the top or bottom.
  func attachBanner(_ bannerView: BannerView, top: Bool) {
    guard let container = topViewController?.view else { return }
    if bannerView.superview !== container {
      bannerView.removeFromSuperview()
      NSLayoutConstraint.deactivate(bannerContainerConstraints)
      bannerView.translatesAutoresizingMaskIntoConstraints = false
      container.addSubview(bannerView)
      let guide = container.safeAreaLayoutGuide
      bannerContainerConstraints = [
        bannerView.centerXAnchor.constraint(equalTo: guide.centerXAnchor),
        top
          ? bannerView.topAnchor.constraint(equalTo: guide.topAnchor)
          : bannerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
      ]
      NSLayoutConstraint.activate(bannerContainerConstraints)
    }
    container.bringSubviewToFront(bannerView)
  }
}

@_cdecl("init_plugin_admob")
func initPlugin() -> Plugin {
  return AdmobPlugin()
}
