// swift-tools-version: 5.7
import PackageDescription

let package = Package(
  name: "store-navigation-controller",
  platforms: [
    .iOS(.v14),
  ],
  products: [
    .library(name: "StoreNavigationController", targets: ["StoreNavigationController"]),
  ],
  targets: [
    .target(
      name: "StoreNavigationController"
    ),
    .testTarget(
      name: "StoreNavigationControllerTests",
      dependencies: [
        .target(name: "StoreNavigationController"),
      ]
    ),
  ]
)
