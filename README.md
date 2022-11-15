# Store Navigation Controller

![Swift 5.7](https://img.shields.io/badge/swift-5.7-orange.svg)
![platform iOS](https://img.shields.io/badge/platform-iOS-blue.svg)

`UINavigationController` driven by [ComposableArchitecture](https://github.com/pointfreeco/swift-composable-architecture)'s `Store`.

⚠️ **NOTICE:** This project is in **beta** phase. It depends on unreleased version of `ComposableArchitecture`. API-breaking changes might be introduced in upcoming releases.

## 📄 Description

Requirements:

- Xcode ≥ 14.1
- iOS ≥ 14
- ComposableArchitecture ≥ ⚠️ (unreleased version, check `Package.swift`)

Add as a dependency to your Xcode project or Swift Package.

Define `Destination` reducer that will be represented by `DestinationViewController` on navigation controller's stack:

```swift
struct Destination: ReducerProtocol {
  struct State: Equatable, Hashable {}

  enum Action: Equatable {
    case pushButtonTapped
  }

  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .pushButtonTapped:
      return .none
    }
  }
}
```

Define `DestinationViewController` that will represent `Destination` on `UINavigationController`'s stack:

```swift
class DestinationViewController: UIViewController, NavigationDestinationViewController {
  let navigationId: AnyHashable
  let store: StoreOf<Destination>

  init(destination: NavigationStateOf<Destination>.Element, store: StoreOf<Destination>) {
    self.navigationId = destination.id
    self.store = store
    // ...
  }

  // ...
}
```

Manage navigation state from your feature reducer:

```swift
struct MyFeature: ReducerProtocol {
  struct State: Equatable {
    @NavigationStateOf<Destination> var navigation
  }

  enum Action: Equatable {
    case navigation(NavigationActionOf<Destination>)
  }

  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .navigation(.element(id: _, .pushButtonTapped)):
        state.navigation.append(Destination.State())
        return .none
      case .navigation(_):
        return .none
      }
    }
    .navigationDestination(
      \.$navigation,
       action: /Action.navigation,
       destinations: Destination.init
    )
  }
}
```
Use `NavigationControllerWithStore`:

```swift
let store: StoreOf<Feature> = ...
let controller = NavigationControllerWithStore(
  store: store.scope(
    state: \.$navigation,
    action: Feature.Action.navigation
  ),
  destinationViewController: DestinationViewController.init(destination:store:)
)
```

For more advanced usage example, check out included example app.

## 📱 Examples

Open `StoreNavigationController.xcworkspace` in Xcode.

You can run example iOS app using `ExampleApp` build scheme.

![Example app](Examples/example-app-dark.gif#gh-dark-mode-only)
![Example app](Examples/example-app-light.gif#gh-light-mode-only)

## 🛠 Development

Open `StoreNavigationController.xcworkspace` in Xcode.

### Project structure

```
StoreNavigationController [Xcode Workspace]
 ├─ store-navigation-controller [Swift Package]
 |   └─ StoreNavigationController [Library]
 └─ Examples [Xcode Project]
     ├─ ExampleApp [iOS App Target]
     └─ example-app [Swift Package]
         ├─ CounterFeature [Library]
         ├─ ExampleFeature [Library]
         └─ TimerFeature [Library]
```

### Build schemes

|Scheme|Description|
|:--|:--|
|`StoreNavigationController`|Build the library and run tests.|
|`ExampleApp`|Build and run example iOS application.|
|`ExampleApp_CounterFeature`|Build example app counter feature library.|
|`ExampleApp_ExampleFeature`|Build example app feature library.|
|`ExampleApp_TimerFeature`|Build example app timer feature library.|

## 📄 License

Copyright © 2022 Dariusz Rybicki Darrarski

License: [MIT](LICENSE)

