import Combine
import ComposableArchitecture
import StoreNavigationController
import UIKit

public struct CounterComponent: ReducerProtocol {
  public struct State: Equatable, Hashable {
    public init(value: Int = 0) {
      self.value = value
    }

    public var value = 0
  }

  public enum Action: Equatable {
    case decrementButtonTapped
    case incrementButtonTapped
    case pushCounterButtonTapped
    case pushTimerButtonTapped
  }

  public init() {}

  public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .decrementButtonTapped:
      state.value -= 1
      return .none

    case .incrementButtonTapped:
      state.value += 1
      return .none

    case .pushCounterButtonTapped:
      return .none

    case .pushTimerButtonTapped:
      return .none
    }
  }
}

public final class CounterViewController: UIViewController, NavigationDestinationViewController {
  public init(navigationId: AnyHashable, store: StoreOf<CounterComponent>) {
    self.navigationId = navigationId
    self.store = store
    self.viewStore = ViewStore(store)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public let navigationId: AnyHashable
  let store: StoreOf<CounterComponent>
  let viewStore: ViewStoreOf<CounterComponent>
  var cancellables = Set<AnyCancellable>()
  let counterLabel = UILabel()
  let decrementButton = UIButton(configuration: .filled())
  let incrementButton = UIButton(configuration: .filled())
  let pushCounterButton = UIButton(configuration: .filled())
  let pushTimerButton = UIButton(configuration: .filled())

  public override func loadView() {
    let view = UIView()
    view.backgroundColor = .systemBackground
    counterLabel.textAlignment = .center
    decrementButton.configuration?.image = UIImage(systemName: "minus")
    incrementButton.configuration?.image = UIImage(systemName: "plus")
    pushCounterButton.configuration?.title = "Push Counter"
    pushTimerButton.configuration?.title = "Push Timer"
    let counterButtonsStack = UIStackView(arrangedSubviews: [
      decrementButton, incrementButton
    ])
    counterButtonsStack.axis = .horizontal
    counterButtonsStack.spacing = 8
    counterButtonsStack.distribution = .fillEqually
    let stack = UIStackView(arrangedSubviews: [
      counterLabel,
      counterButtonsStack,
      pushCounterButton,
      pushTimerButton,
    ])
    stack.axis = .vertical
    stack.spacing = 8
    view.addSubview(stack)
    stack.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])
    self.view = view
  }

  public override func viewDidLoad() {
    super.viewDidLoad()

    viewStore.publisher.map(\.value)
      .removeDuplicates()
      .sink { [unowned self] value in
        counterLabel.text = "\(value)"
        navigationItem.title = "Counter (\(value))"
      }
      .store(in: &cancellables)

    decrementButton.addAction(.init(handler: { [unowned self] _ in
      viewStore.send(.decrementButtonTapped)
    }), for: .touchUpInside)

    incrementButton.addAction(.init(handler: { [unowned self] _ in
      viewStore.send(.incrementButtonTapped)
    }), for: .touchUpInside)

    pushCounterButton.addAction(.init(handler: { [unowned self] _ in
      viewStore.send(.pushCounterButtonTapped)
    }), for: .touchUpInside)

    pushTimerButton.addAction(.init(handler: { [unowned self] _ in
      viewStore.send(.pushTimerButtonTapped)
    }), for: .touchUpInside)
  }
}
