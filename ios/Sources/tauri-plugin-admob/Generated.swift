import Foundation

/// Event names emitted to the JS side. Kept in sync with the Android
/// `Generated.Events` constants so listeners behave identically on both platforms.
enum Events {
  static let bannerClick = "banner_click"
  static let bannerClose = "banner_close"
  static let bannerImpression = "banner_impression"
  static let bannerLoad = "banner_load"
  static let bannerLoadFail = "banner_load_fail"
  static let bannerOpen = "banner_open"

  static let interstitialDismiss = "interstitial_dismiss"
  static let interstitialImpression = "interstitial_impression"
  static let interstitialLoad = "interstitial_load"
  static let interstitialLoadFail = "interstitial_load_fail"
  static let interstitialShow = "interstitial_show"
  static let interstitialShowFail = "interstitial_show_fail"

  static let rewardedInterstitialDismiss = "rewardedInterstitial_dismiss"
  static let rewardedInterstitialImpression = "rewardedInterstitial_impression"
  static let rewardedInterstitialLoad = "rewardedInterstitial_load"
  static let rewardedInterstitialLoadFail = "rewardedInterstitial_load_fail"
  static let rewardedInterstitialReward = "rewardedInterstitial_reward"
  static let rewardedInterstitialShow = "rewardedInterstitial_show"
  static let rewardedInterstitialShowFail = "rewardedInterstitial_show_fail"

  static let rewardedDismiss = "rewarded_dismiss"
  static let rewardedImpression = "rewarded_impression"
  static let rewardedLoad = "rewarded_load"
  static let rewardedLoadFail = "rewarded_load_fail"
  static let rewardedReward = "rewarded_reward"
  static let rewardedShow = "rewarded_show"
  static let rewardedShowFail = "rewarded_show_fail"
}
