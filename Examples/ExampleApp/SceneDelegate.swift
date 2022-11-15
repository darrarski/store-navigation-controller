import ComposableArchitecture
import ExampleFeature
import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    guard let windowScene = scene as? UIWindowScene else { return }
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = ExampleViewController(store: Store(
      initialState: ExampleComponent.State(navigation: [
        .counter(.init()),
      ]),
      reducer: ExampleComponent()
    ))
    window?.makeKeyAndVisible()
  }
}
