import Combine
import ExpoModulesCore
import FamilyControls
import SwiftUI
import UIKit

// This view will be used as a native component. Make sure to inherit from `ExpoView`
// to apply the proper styling (e.g. border radius and shadows).
@available(iOS 15.0, *)
class ReactNativeDeviceActivityView: ExpoView {

  let model = ScreenTimeSelectAppsModel()

  let contentView: UIHostingController<ScreenTimeSelectAppsContentView>

  private var cancellables = Set<AnyCancellable>()

  required init(appContext: AppContext? = nil) {
    contentView = UIHostingController(
      rootView: ScreenTimeSelectAppsContentView(
        model: model
      )
    )

    super.init(appContext: appContext)

    clipsToBounds = true

    // Configure the hosting controller
    contentView.view.backgroundColor = .clear
    contentView.view.translatesAutoresizingMaskIntoConstraints = false

    // Add the view directly
    addSubview(contentView.view)

    // Setup constraints
    NSLayoutConstraint.activate([
      contentView.view.topAnchor.constraint(equalTo: topAnchor),
      contentView.view.leadingAnchor.constraint(equalTo: leadingAnchor),
      contentView.view.trailingAnchor.constraint(equalTo: trailingAnchor),
      contentView.view.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])

    // Find root view controller and add content view controller as child
    if let rootViewController = UIApplication.shared.windows.first?.rootViewController {
      rootViewController.addChild(contentView)
      contentView.didMove(toParent: rootViewController)
    }

    model.$activitySelection.debounce(for: .seconds(0.1), scheduler: RunLoop.main).sink {
      selection in
      if selection != self.previousSelection {
        self.previousSelection = selection
        self.updateSelection(selection: selection)
      }
    }
    .store(in: &cancellables)
  }

  let onSelectionChange = EventDispatcher()

  var previousSelection: FamilyActivitySelection?

  func updateSelection(selection: FamilyActivitySelection) {
    let familyActivitySelectionString = serializeFamilyActivitySelection(
      selection: selection
    )

    onSelectionChange([
      "familyActivitySelection": familyActivitySelectionString as Any,
      "applicationCount": selection.applicationTokens.count,
      "categoryCount": selection.categoryTokens.count,
      "webDomainCount": selection.webDomainTokens.count,
    ])
  }
}
