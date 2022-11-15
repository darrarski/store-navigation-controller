import Combine
import ComposableArchitecture
import StoreNavigationController
import UIKit

public struct TimerComponent: ReducerProtocol {
  public struct State: Equatable, Hashable {
    public init(value: Int = 0, isTimerRunning: Bool = false) {
      self.value = value
      self.isTimerRunning = isTimerRunning
    }

    public var value = 0
    public var isTimerRunning = false
  }

  public enum Action: Equatable {
    case timerButtonTapped
    case timerTick
    case pushCounterButtonTapped
    case pushTimerButtonTapped
  }

  public init() {}

  @Dependency(\.mainQueue) var mainQueue
  enum TimerID {}

  public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .timerButtonTapped:
      if state.isTimerRunning {
        state.isTimerRunning = false
        return .cancel(id: TimerID.self)
      } else {
        state.isTimerRunning = true
        return .run { send in
          for await _ in self.mainQueue.timer(interval: 1) {
            await send(.timerTick)
          }
        }
        .cancellable(id: TimerID.self, cancelInFlight: true)
      }

    case .timerTick:
      state.value += 1
      return .none

    case .pushCounterButtonTapped:
      return .none

    case .pushTimerButtonTapped:
      return .none
    }
  }
}

public final class TimerViewController: UIViewController, NavigationDestinationViewController {
  public init(navigationId: AnyHashable, store: StoreOf<TimerComponent>) {
    self.navigationId = navigationId
    self.store = store
    self.viewStore = ViewStore(store)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public let navigationId: AnyHashable
  let store: StoreOf<TimerComponent>
  let viewStore: ViewStoreOf<TimerComponent>
  var cancellables = Set<AnyCancellable>()
  let timerLabel = UILabel()
  let timerButton = UIButton(configuration: .filled())
  let pushCounterButton = UIButton(configuration: .filled())
  let pushTimerButton = UIButton(configuration: .filled())

  public override func loadView() {
    let view = UIView()
    view.backgroundColor = .systemBackground
    timerLabel.textAlignment = .center
    pushCounterButton.configuration?.title = "Push Counter"
    pushTimerButton.configuration?.title = "Push Timer"
    let stack = UIStackView(arrangedSubviews: [
      timerLabel,
      timerButton,
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
        timerLabel.text = "\(value)"
        navigationItem.title = "Timer (\(value))"
      }
      .store(in: &cancellables)

    viewStore.publisher.map(\.isTimerRunning)
      .removeDuplicates()
      .sink { [unowned self] isTimerRunning in
        timerButton.configuration?.title = isTimerRunning ? "Stop timer" : "Start timer"
      }
      .store(in: &cancellables)

    timerButton.addAction(.init(handler: { [unowned self] _ in
      viewStore.send(.timerButtonTapped)
    }), for: .touchUpInside)

    pushCounterButton.addAction(.init(handler: { [unowned self] _ in
      viewStore.send(.pushCounterButtonTapped)
    }), for: .touchUpInside)

    pushTimerButton.addAction(.init(handler: { [unowned self] _ in
      viewStore.send(.pushTimerButtonTapped)
    }), for: .touchUpInside)
  }
}
