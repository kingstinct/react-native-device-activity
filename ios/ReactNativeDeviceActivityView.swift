import SwiftUI
import ExpoModulesCore
import FamilyControls
import UIKit
import Combine

// This view will be used as a native component. Make sure to inherit from `ExpoView`
// to apply the proper styling (e.g. border radius and shadows).
@available(iOS 15.0, *)
class ReactNativeDeviceActivityView: ExpoView {
  
  
  public let model = DeviceActivityModel.current
  
  let contentView: UIHostingController<ScreenTimeSelectAppsContentView>
  
  private var cancellables = Set<AnyCancellable>()

  required init(appContext: AppContext? = nil) {
    contentView = UIHostingController(rootView: ScreenTimeSelectAppsContentView(model: model.model))
    
    super.init(appContext: appContext)
    
    clipsToBounds = true
    
    self.addSubview(contentView.view)
    
    model.model.$activitySelection.sink { selection in
        self.saveSelection(selection: selection)
    }
    .store(in: &cancellables)
  }
  
  override func layoutSubviews() {
    contentView.view.frame = bounds
  }
  
  func saveSelection(selection: FamilyActivitySelection) {
    self.appContext?.eventEmitter?.sendEvent(withName: "onSelectionChange", body: [
      "apps": selection.applications.map({ app in
        return app.bundleIdentifier
      }),
      "categories": selection.categories.map({ app in
        return app.localizedDisplayName
      }),
      "sites": selection.webDomains.map({ app in
        return app.domain
      })
    ])

    model.saveSelection(selection: selection)
  }
}
