import Combine
import ComposableArchitecture
import UIKit

struct Counter: ReducerProtocol {
  struct State: Equatable {
    var value = 0
  }

  enum Action: Equatable {
    case decrementButtonTapped
    case incrementButtonTapped
    case pushCounterButtonTapped
    case pushTimerButtonTapped
  }

  func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
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

final class CounterViewController: UIViewController {
  init(store: StoreOf<Counter>) {
    self.store = store
    self.viewStore = ViewStore(store)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  let store: StoreOf<Counter>
  let viewStore: ViewStoreOf<Counter>
  var cancellables = Set<AnyCancellable>()
  let counterLabel = UILabel()
  let decrementButton = UIButton(configuration: .filled())
  let incrementButton = UIButton(configuration: .filled())
  let pushCounterButton = UIButton(configuration: .filled())
  let pushTimerButton = UIButton(configuration: .filled())

  override func loadView() {
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

  override func viewDidLoad() {
    super.viewDidLoad()

    viewStore.publisher.map(\.value)
      .removeDuplicates()
      .sink { [unowned self] value in
        counterLabel.text = "\(value)"
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
