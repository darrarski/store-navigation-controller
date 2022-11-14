import UIKit

public final class NavigationControllerWithStore: UIViewController {
  public init() {
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override func loadView() {
    let view = UIView()
    view.backgroundColor = .systemTeal
    self.view = view
  }
}
