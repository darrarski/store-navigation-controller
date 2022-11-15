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
    store = Store(
      initialState: NavigationStateOf<Destination>(),
      reducer: EmptyReducer()
        .navigationDestination(\.self, action: /.self) {
          Destination()
        }
    )
    viewStore = ViewStore(store)
    navigationController = UINavigationController()
    sut = NavigationControllerWithStore(
      store: store,
      navigationController: navigationController,
      destinationViewController: DestinationViewController.init(destination:store:)
    )
  }

  override func tearDown() {
    super.tearDown()
    sut = nil
    navigationController = nil
    viewStore = nil
    store = nil
  }

  func testExample() throws {
    // TODO:
    XCTAssert(true)
  }
}
