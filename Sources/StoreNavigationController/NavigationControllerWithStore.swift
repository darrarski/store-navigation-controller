import Collections
import Combine
import ComposableArchitecture
import UIKit

public final class NavigationControllerWithStore<Element>
: UINavigationController,
  UINavigationControllerDelegate
where Element: ReducerProtocol,
      Element.State: Hashable
{
  public init(
    store: Store<NavigationStateOf<Element>, NavigationActionOf<Element>>,
    navigationController: UINavigationController = .init(navigationBarClass: nil, toolbarClass: nil),
    elementViewController: @escaping (StoreOf<Element>) -> UIViewController
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
  let elementViewController: (StoreOf<Element>) -> UIViewController
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
        let presentedViewControllers: [ViewController] = controlledNavigationController
          .viewControllers
          .compactMap { $0 as? ViewController }
        if state.ids == OrderedSet(presentedViewControllers.map(\.id)) {
          return
        }
        let viewControllers: [ViewController] = state.map { destination in
          if let viewController = presentedViewControllers.first(where: { $0.id == destination.id }) {
            return viewController
          }
          return ViewController(
            id: destination.id,
            elementViewController: elementViewController(store.scope(
              state: { $0[id: destination.id] ?? destination.element },
              action: { NavigationActionOf<Element>.element(id: destination.id, $0) }
            ))
          )
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
    let presentedViewControllers: [ViewController] = controlledNavigationController
      .viewControllers
      .compactMap { $0 as? ViewController }
    if viewStore.ids == OrderedSet(presentedViewControllers.map(\.id)) {
      return
    }
    var newState = NavigationStateOf<Element>()
    presentedViewControllers.forEach { viewController in
      newState[id: viewController.id] = viewStore.state[id: viewController.id]
    }
    viewStore.send(.setPath(newState))
  }

  final class ViewController: UIViewController {
    init(id: AnyHashable, elementViewController: UIViewController) {
      self.id = id
      self.elementViewController = elementViewController
      super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    let id: AnyHashable
    let elementViewController: UIViewController

    override var title: String? {
      get { elementViewController.title }
      set { elementViewController.title = newValue }
    }

    override func viewDidLoad() {
      super.viewDidLoad()

      addChild(elementViewController)
      view.addSubview(elementViewController.view)
      elementViewController.view.frame = view.bounds
      elementViewController.didMove(toParent: self)
    }
  }
}
