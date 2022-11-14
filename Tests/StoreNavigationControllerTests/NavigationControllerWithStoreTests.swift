import XCTest
@testable import StoreNavigationController

final class NavigationControllerWithStoreTests: XCTestCase {
  var controller: NavigationControllerWithStore!

  override func tearDown() {
    super.tearDown()
    controller = nil
  }

  func testExample() throws {
    controller = NavigationControllerWithStore()

    XCTAssert(true)
  }
}
