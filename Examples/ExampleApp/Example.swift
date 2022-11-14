import ComposableArchitecture
import StoreNavigationController
import UIKit

struct Example: ReducerProtocol {
  struct State: Equatable {
    @NavigationStateOf<Destination> var navigation
  }

  enum Action: Equatable {
    case navigation(NavigationActionOf<Destination>)
  }

  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .navigation(.element(id: _, .counter(.pushCounterButtonTapped))),
          .navigation(.element(id: _, .timer(.pushCounterButtonTapped))):
        state.navigation.append(.counter(.init()))
        return .none

      case .navigation(.element(id: _, .counter(.pushTimerButtonTapped))),
          .navigation(.element(id: _, .timer(.pushTimerButtonTapped))):
        state.navigation.append(.timer(.init()))
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

    let navigationController = NavigationControllerWithStore<Destination>(
      store: store.scope(
        state: \.$navigation,
        action: Example.Action.navigation
      ),
      elementViewController: DestinationViewController.init(navigationId:store:)
    )
    addChild(navigationController)
    view.addSubview(navigationController.view)
    navigationController.view.frame = view.bounds
    navigationController.didMove(toParent: self)
  }
}
