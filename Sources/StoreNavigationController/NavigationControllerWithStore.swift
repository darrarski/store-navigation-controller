import Collections
import Combine
import ComposableArchitecture
import UIKit

public protocol NavigationStateElementViewController: UIViewController {
  var navigationId: AnyHashable { get }
}

public final class NavigationControllerWithStore<Element>
: UINavigationController,
  UINavigationControllerDelegate
where Element: ReducerProtocol,
      Element.State: Hashable
{
  public typealias ElementViewController = NavigationStateElementViewController
  public typealias MakeElementViewController = (NavigationStateOf<Element>.Element, StoreOf<Element>) -> ElementViewController

  public init(
    store: Store<NavigationStateOf<Element>, NavigationActionOf<Element>>,
    navigationController: UINavigationController = .init(navigationBarClass: nil, toolbarClass: nil),
    elementViewController: @escaping MakeElementViewController
  ) {
    self.store = store
    self.viewStore = ViewStore(self.store)
    self.controlledNavigationController = navigationController
    self.elementViewController = elementViewController
    super.init(navigationBarClass: nil, toolbarClass: nil)
    navigationController.delegate = self
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  let store: Store<NavigationStateOf<Element>, NavigationActionOf<Element>>
  let viewStore: ViewStore<NavigationStateOf<Element>, NavigationActionOf<Element>>
  let controlledNavigationController: UINavigationController
  let elementViewController: MakeElementViewController
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
        let presentedViewControllers: [ElementViewController] = controlledNavigationController
          .viewControllers
          .compactMap { $0 as? ElementViewController }
        if state.ids == OrderedSet(presentedViewControllers.map(\.navigationId)) {
          return
        }
        let viewControllers: [ElementViewController] = state.map { destination in
          if let viewController = presentedViewControllers
            .first(where: { $0.navigationId == destination.id }) {
            return viewController
          }
          return elementViewController(destination, store.scope(
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
    let presentedViewControllers: [ElementViewController] = controlledNavigationController
      .viewControllers
      .compactMap { $0 as? ElementViewController }
    if viewStore.ids == OrderedSet(presentedViewControllers.map(\.navigationId)) {
      return
    }
    var newState = NavigationStateOf<Element>()
    presentedViewControllers.forEach { viewController in
      let id = viewController.navigationId
      newState[id: id] = viewStore.state[id: id]
    }
    viewStore.send(.setPath(newState))
  }
}
