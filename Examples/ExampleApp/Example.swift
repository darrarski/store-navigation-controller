import Combine
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
    self.viewStore = ViewStore(store)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  let store: StoreOf<Example>
  let viewStore: ViewStoreOf<Example>
  var cancellables = Set<AnyCancellable>()
  let sumLabel = UILabel()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    let navigationController = NavigationControllerWithStore<Destination>(
      store: store.scope(
        state: \.$navigation,
        action: Example.Action.navigation
      ),
      elementViewController: DestinationViewController.init(navigationId:store:)
    )
    addChild(navigationController)
    view.addSubview(navigationController.view)
    navigationController.view.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(sumLabel)
    sumLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      navigationController.view.topAnchor.constraint(equalTo: view.topAnchor),
      navigationController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
      navigationController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
      sumLabel.topAnchor.constraint(equalTo: navigationController.view.bottomAnchor),
      sumLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      sumLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
    ])
    navigationController.didMove(toParent: self)

    viewStore.publisher
      .map {
        $0.navigation.map { state in
          switch state {
          case .timer(let state): return state.value
          case .counter(let state): return state.value
          }
        }
        .reduce(Int.zero, +)
      }
      .removeDuplicates()
      .sink { [unowned self] sum in
        sumLabel.text = "Sum: \(sum)"
      }
      .store(in: &cancellables)
  }
}
