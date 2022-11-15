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
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", revision: "f87cf838803e2b203039fa76e6626f4a63e5c81b"),
    .package(url: "https://github.com/apple/swift-collections", .upToNextMajor(from: "1.0.3")),
  ],
  targets: [
    .target(
      name: "StoreNavigationController",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Collections", package: "swift-collections"),
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
