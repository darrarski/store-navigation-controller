import Combine
import ComposableArchitecture
import StoreNavigationController
import UIKit

struct Destination: ReducerProtocol {
  enum State: Equatable, Hashable {
    case timer(Timer.State)
    case counter(Counter.State)
  }

  enum Action: Equatable {
    case timer(Timer.Action)
    case counter(Counter.Action)
  }

  var body: some ReducerProtocol<State, Action> {
    Scope(state: /State.counter, action: /Action.counter) {
      Counter()
    }
    Scope(state: /State.timer, action: /Action.timer) {
      Timer()
    }
  }
}

final class DestinationViewController: UIViewController, NavigationStateElementViewController {
  init(navigationId: AnyHashable, store: StoreOf<Destination>) {
    self.navigationId = navigationId
    self.store = store
    self.viewStore = ViewStore(store)
    super.init(nibName: nil, bundle: nil)

    store.scope(
      state: (/Destination.State.counter).extract(from:),
      action: Destination.Action.counter
    )
    .ifLet { [unowned self] store in
      viewController = CounterViewController(store: store)
    }
    .store(in: &cancellables)

    store.scope(
      state: (/Destination.State.timer).extract(from:),
      action: Destination.Action.timer
    )
    .ifLet { [unowned self] store in
      viewController = TimerViewController(store: store)
    }
    .store(in: &cancellables)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  let navigationId: AnyHashable
  let store: StoreOf<Destination>
  let viewStore: ViewStoreOf<Destination>
  var cancellables = Set<AnyCancellable>()

  override var title: String? {
    get { viewController?.title }
    set { viewController?.title = newValue }
  }

  var viewController: UIViewController? {
    didSet {
      oldValue?.willMove(toParent: nil)
      oldValue?.view.removeFromSuperview()
      oldValue?.removeFromParent()

      if let viewController {
        addChild(viewController)
        view.addSubview(viewController.view)
        viewController.view.frame = view.bounds
        viewController.didMove(toParent: self)
      }
    }
  }
}
