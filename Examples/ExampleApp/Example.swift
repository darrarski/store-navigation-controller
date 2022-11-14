import ComposableArchitecture
import StoreNavigationController
import UIKit

struct Example: ReducerProtocol {
  struct State: Equatable {}

  enum Action: Equatable {}

  var body: some ReducerProtocol<State, Action> {
    EmptyReducer()
  }
}

final class ExampleViewController: UIViewController {
  init(store: StoreOf<Example>) {
    self.store = store
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  let store: StoreOf<Example>

  override func viewDidLoad() {
    super.viewDidLoad()

    let navigationController = NavigationControllerWithStore()
    addChild(navigationController)
    view.addSubview(navigationController.view)
    navigationController.view.frame = view.bounds
    navigationController.didMove(toParent: self)
  }
}
