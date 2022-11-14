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
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", branch: "navigation"),
  ],
  targets: [
    .target(
      name: "StoreNavigationController",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(
      name: "StoreNavigationControllerTests",
      dependencies: [
        .target(name: "StoreNavigationController"),
      ]
    ),
  ]
)
