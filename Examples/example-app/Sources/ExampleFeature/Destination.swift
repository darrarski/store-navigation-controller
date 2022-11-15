import Combine
import ComposableArchitecture
import CounterFeature
import StoreNavigationController
import TimerFeature
import UIKit

public struct Destination: ReducerProtocol {
  public enum State: Equatable, Hashable {
    case timer(TimerComponent.State)
    case counter(CounterComponent.State)
  }

  public enum Action: Equatable {
    case timer(TimerComponent.Action)
    case counter(CounterComponent.Action)
  }

  public init() {}

  public var body: some ReducerProtocol<State, Action> {
    Scope(state: /State.counter, action: /Action.counter) {
      CounterComponent()
    }
    Scope(state: /State.timer, action: /Action.timer) {
      TimerComponent()
    }
  }
}

func destinationViewController(
  destination: NavigationStateOf<Destination>.Element,
  store: StoreOf<Destination>
) -> NavigationDestinationViewController {
  switch destination.element {
  case .counter(let state):
    return CounterViewController(
      navigationId: destination.id,
      store: store.scope(
        state: { (/Destination.State.counter).extract(from: $0) ?? state },
        action: Destination.Action.counter
      )
    )
  case .timer(let state):
    return TimerViewController(
      navigationId: destination.id,
      store: store.scope(
        state: { (/Destination.State.timer).extract(from: $0) ?? state },
        action: Destination.Action.timer
      )
    )
  }
}
