// swift-tools-version:5.3
// Copyright 2019-2024 Tauri Programme within The Commons Conservancy
// SPDX-License-Identifier: Apache-2.0
// SPDX-License-Identifier: MIT

import PackageDescription

let package = Package(
  name: "tauri-plugin-admob",
  platforms: [
    .iOS(.v13)
  ],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "tauri-plugin-admob",
      type: .static,
      targets: ["tauri-plugin-admob"])
  ],
  dependencies: [
    .package(name: "Tauri", path: "../.tauri/tauri-api"),
    .package(
      url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git",
      from: "12.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "tauri-plugin-admob",
      dependencies: [
        .byName(name: "Tauri"),
        .product(
          name: "GoogleMobileAds",
          package: "swift-package-manager-google-mobile-ads"),
      ],
      path: "Sources/tauri-plugin-admob")
  ]
)
