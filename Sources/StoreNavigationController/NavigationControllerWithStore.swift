import Collections
import Combine
import ComposableArchitecture
import UIKit

public protocol NavigationDestinationViewController: UIViewController {
  var navigationId: AnyHashable { get }
}

public final class NavigationControllerWithStore<Destination>
: UINavigationController,
  UINavigationControllerDelegate
where Destination: ReducerProtocol,
      Destination.State: Hashable
{
  public typealias DestinationViewController = NavigationDestinationViewController
  public typealias MakeDestinationViewController = (NavigationStateOf<Destination>.Element, StoreOf<Destination>) -> DestinationViewController

  public init(
    store: Store<NavigationStateOf<Destination>, NavigationActionOf<Destination>>,
    navigationController: UINavigationController = .init(navigationBarClass: nil, toolbarClass: nil),
    destinationViewController: @escaping MakeDestinationViewController
  ) {
    self.store = store
    self.viewStore = ViewStore(self.store)
    self.controlledNavigationController = navigationController
    self.destinationViewController = destinationViewController
    super.init(navigationBarClass: nil, toolbarClass: nil)
    navigationController.delegate = self
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  let store: Store<NavigationStateOf<Destination>, NavigationActionOf<Destination>>
  let viewStore: ViewStore<NavigationStateOf<Destination>, NavigationActionOf<Destination>>
  let controlledNavigationController: UINavigationController
  let destinationViewController: MakeDestinationViewController
  var cancellables = Set<AnyCancellable>()

  public override func viewDidLoad() {
    super.viewDidLoad()

    addChild(controlledNavigationController)
    view.addSubview(controlledNavigationController.view)
    controlledNavigationController.view.frame = view.bounds
    controlledNavigationController.didMove(toParent: self)

    viewStore.publisher
      .removeDuplicates { $0.ids == $1.ids }
      .sink { [unowned self] state in
        let presentedViewControllers: [DestinationViewController] = controlledNavigationController
          .viewControllers
          .compactMap { $0 as? DestinationViewController }
        if state.ids == OrderedSet(presentedViewControllers.map(\.navigationId)) {
          return
        }
        let viewControllers: [DestinationViewController] = state.map { destination in
          if let viewController = presentedViewControllers
            .first(where: { $0.navigationId == destination.id }) {
            return viewController
          }
          return destinationViewController(destination, store.scope(
            state: { $0[id: destination.id] ?? destination.element },
            action: { .element(id: destination.id, $0) }
          ))
        }
        let animate = controlledNavigationController.viewControllers.isEmpty == false
        controlledNavigationController.setViewControllers(viewControllers, animated: animate)
      }
      .store(in: &cancellables)
  }

  public func navigationController(
    _ navigationController: UINavigationController,
    didShow viewController: UIViewController,
    animated: Bool
  ) {
    let presentedViewControllers: [DestinationViewController] = controlledNavigationController
      .viewControllers
      .compactMap { $0 as? DestinationViewController }
    if viewStore.ids == OrderedSet(presentedViewControllers.map(\.navigationId)) {
      return
    }
    var newState = NavigationStateOf<Destination>()
    presentedViewControllers.forEach { viewController in
      let id = viewController.navigationId
      newState[id: id] = viewStore.state[id: id]
    }
    viewStore.send(.setPath(newState))
  }
}
