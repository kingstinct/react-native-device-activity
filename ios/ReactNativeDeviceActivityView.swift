import SwiftUI
import ExpoModulesCore
import FamilyControls
import UIKit
import Combine

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

        self.addSubview(contentView.view)

        model.$activitySelection.debounce(for: .seconds(0.1), scheduler: RunLoop.main).sink { selection in
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
        let encoder = JSONEncoder()
        do {
            let json = try encoder.encode(selection)
            let jsonString = json.base64EncodedString()

            onSelectionChange([
                "familyActivitySelection": jsonString,
                "applicationCount": selection.applicationTokens.count,
                "categoryCount": selection.categoryTokens.count,
                "webDomainCount": selection.webDomainTokens.count
            ])
        } catch {

        }

        // model.saveSelection(selection: selection)
    }
}
