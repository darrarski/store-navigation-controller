import Combine
import ComposableArchitecture
import StoreNavigationController
import UIKit

struct Destination: ReducerProtocol {
  enum State: Equatable, Hashable {
    case timer(Timer.State)
    case counter(Counter.State)
  }

  enum Action: Equatable {
    case timer(Timer.Action)
    case counter(Counter.Action)
  }

  var body: some ReducerProtocol<State, Action> {
    Scope(state: /State.counter, action: /Action.counter) {
      Counter()
    }
    Scope(state: /State.timer, action: /Action.timer) {
      Timer()
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
