// swift-tools-version: 5.7
import PackageDescription

let package = Package(
  name: "example-app",
  platforms: [
    .iOS(.v15),
  ],
  products: [
    .library(name: "CounterFeature", targets: ["CounterFeature"]),
    .library(name: "ExampleFeature", targets: ["ExampleFeature"]),
    .library(name: "TimerFeature", targets: ["TimerFeature"]),
  ],
  dependencies: [
    .package(path: "../../"),
  ],
  targets: [
    .target(
      name: "CounterFeature",
      dependencies: [
        .product(name: "StoreNavigationController", package: "store-navigation-controller"),
      ]
    ),
    .target(
      name: "ExampleFeature",
      dependencies: [
        .target(name: "CounterFeature"),
        .target(name: "TimerFeature"),
        .product(name: "StoreNavigationController", package: "store-navigation-controller"),
      ]
    ),
    .target(
      name: "TimerFeature",
      dependencies: [
        .product(name: "StoreNavigationController", package: "store-navigation-controller"),
      ]
    ),
  ]
)
