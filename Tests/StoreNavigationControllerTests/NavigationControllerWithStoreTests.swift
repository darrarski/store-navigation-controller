import ComposableArchitecture
import XCTest
@testable import StoreNavigationController

final class NavigationControllerWithStoreTests: XCTestCase {
  struct Destination: ReducerProtocol {
    struct State: Equatable, Hashable {}
    enum Action: Equatable {}
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {}
  }

  final class DestinationViewController: UIViewController, NavigationDestinationViewController {
    init(destination: NavigationStateOf<Destination>.Element, store: StoreOf<Destination>) {
      self.navigationId = destination.id
      self.store = store
      super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    let navigationId: AnyHashable
    let store: StoreOf<Destination>
  }

  var store: Store<NavigationStateOf<Destination>, NavigationActionOf<Destination>>!
  var viewStore: ViewStore<NavigationStateOf<Destination>, NavigationActionOf<Destination>>!
  var navigationController: UINavigationController!
  var sut: NavigationControllerWithStore<Destination>!

  override func setUp() {
    super.setUp()
    UIView.setAnimationsEnabled(false)
    store = Store(
      initialState: NavigationStateOf<Destination>(),
      reducer: EmptyReducer()
        .navigationDestination(\.self, action: /.self) {
          Destination()
        }
    )
    viewStore = ViewStore(store)
    navigationController = NavigationController()
    sut = NavigationControllerWithStore(
      store: store,
      navigationController: navigationController,
      destinationViewController: DestinationViewController.init(destination:store:)
    )
  }

  override func tearDown() {
    super.tearDown()
    UIView.setAnimationsEnabled(true)
    sut = nil
    navigationController = nil
    viewStore = nil
    store = nil
  }

  func testNavigation() throws {
    // Load view:
    _ = sut.view

    // Put two elements on the stack:
    viewStore.send(.setPath(.init(
      dictionaryLiteral: (1, .init()), (2, .init())
    )))

    let viewControllers = navigationController.viewControllers
    XCTAssertNoDifference(
      viewControllers
        .map { $0 as? NavigationDestinationViewController }
        .map(\.?.navigationId),
      [1, 2]
    )

    // Push third element on the stack:
    viewStore.send(.setPath(.init(
      dictionaryLiteral: (1, .init()), (2, .init()), (3, .init())
    )))

    XCTAssertNoDifference(
      navigationController.viewControllers
        .map { $0 as? NavigationDestinationViewController }
        .map(\.?.navigationId),
      [1, 2, 3]
    )
    XCTAssertNoDifference(
      navigationController.viewControllers,
      viewControllers + [navigationController.viewControllers.last]
    )

    // Pop view controller:
    navigationController.popViewController(animated: false)
    navigationController.delegate?.navigationController?(
      navigationController,
      didShow: navigationController.viewControllers.last!,
      animated: false
    )

    XCTAssertNoDifference(viewStore.state, .init(
      dictionaryLiteral: (1, .init()), (2, .init())
    ))
  }
}

private final class NavigationController: UINavigationController {
  override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
    super.setViewControllers(viewControllers, animated: false)
  }
}
