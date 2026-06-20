# Tauri Plugin admob — iOS

AdMob support for iOS, implemented on top of the [Google Mobile Ads SDK][gma]
via Swift Package Manager.

## Supported ad types

- Banner
- Interstitial
- Rewarded
- Rewarded interstitial

These mirror the Android implementation and emit the same events to the JS side.

## Consent & privacy

On startup the plugin initializes the Mobile Ads SDK and requests consent
information through the [User Messaging Platform][ump], presenting the consent
form when required. The `isPrivacyOptionsRequired` and `showPrivacyOptionsForm`
commands let the app surface the privacy options form on demand.

App Tracking Transparency is exposed through `requestTrackingAuthorization` and
`trackingAuthorizationStatus`.

## App configuration

The consuming app must declare its AdMob application id and (for iOS 14+) the
`NSUserTrackingUsageDescription` string in its `Info.plist`, and add
`GADApplicationIdentifier`. See the [Get started guide][getstarted].

[gma]: https://developers.google.com/admob/ios/quick-start
[ump]: https://developers.google.com/admob/ios/privacy
[getstarted]: https://developers.google.com/admob/ios/quick-start
