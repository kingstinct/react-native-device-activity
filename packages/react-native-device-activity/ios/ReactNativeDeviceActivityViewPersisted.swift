import Combine
import ExpoModulesCore
import FamilyControls
import SwiftUI
import UIKit

@available(iOS 15.0, *)
class ReactNativeDeviceActivityViewPersisted: ExpoView {

  let model = ScreenTimeSelectAppsModel()

  let contentView: UIHostingController<ActivityPicker>

  private var cancellables = Set<AnyCancellable>()

  required init(appContext: AppContext? = nil) {
    contentView = UIHostingController(
      rootView: ActivityPicker(
        model: model
      )
    )

    super.init(appContext: appContext)

    clipsToBounds = true
    backgroundColor = .clear
    isUserInteractionEnabled = false

    contentView.view.backgroundColor = .clear
    contentView.view.isUserInteractionEnabled = false

    self.addSubview(contentView.view)

    model.$activitySelection.debounce(for: .seconds(0.1), scheduler: RunLoop.main).sink {
      selection in
      if selection != self.previousSelection {
        self.previousSelection = selection
        self.updateSelection(selection: selection)
      }
    }
    .store(in: &cancellables)
  }

  override func layoutSubviews() {
    contentView.view.frame = bounds
  }

  let onSelectionChange = EventDispatcher()

  var previousSelection: FamilyActivitySelection?

  func updateSelection(selection: FamilyActivitySelection) {
    if let activitySelectionId = model.activitySelectionId {
      let isSelectionNonEmpty =
        selection.applicationTokens.count > 0 || selection.webDomainTokens.count > 0
        || selection.categoryTokens
          .count > 0

      if isSelectionNonEmpty {
        setFamilyActivitySelectionById(
          id: activitySelectionId,
          activitySelection: selection
        )
      } else {
        // remove to allow for reinitializing the selection, with whatever the includeEntireCategory setting is
        removeFamilyActivitySelectionById(id: activitySelectionId)
      }

      if #available(iOS 15.2, *) {
        onSelectionChange([
          "applicationCount": selection.applicationTokens.count,
          "categoryCount": selection.categoryTokens.count,
          "webDomainCount": selection.webDomainTokens.count,
          "includeEntireCategory": selection.includeEntireCategory
        ])
      } else {
        onSelectionChange([
          "applicationCount": selection.applicationTokens.count,
          "categoryCount": selection.categoryTokens.count,
          "webDomainCount": selection.webDomainTokens.count
        ])
      }
    }
  }
}
