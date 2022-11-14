import StoreNavigationController
import UIKit

final class ExampleViewController: UIViewController {
  init() {
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let navigationController = NavigationControllerWithStore()
    addChild(navigationController)
    view.addSubview(navigationController.view)
    navigationController.view.frame = view.bounds
    navigationController.didMove(toParent: self)
  }
}
