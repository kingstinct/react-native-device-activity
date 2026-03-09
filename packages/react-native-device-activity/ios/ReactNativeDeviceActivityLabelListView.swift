import ExpoModulesCore
import FamilyControls
import SwiftUI
import UIKit

@available(iOS 15.0, *)
class ReactNativeDeviceActivityLabelListView: ExpoView {

  let model = ActivityLabelListModel()

  let contentView: UIHostingController<ActivityLabelList>

  let onContentSizeChange = EventDispatcher()

  private var lastReportedHeight: CGFloat = 0

  required init(appContext: AppContext? = nil) {
    contentView = UIHostingController(
      rootView: ActivityLabelList(model: model)
    )

    super.init(appContext: appContext)

    clipsToBounds = false
    backgroundColor = .clear

    contentView.view.backgroundColor = .clear

    self.addSubview(contentView.view)
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let targetWidth = bounds.width > 0 ? bounds.width : UIView.layoutFittingExpandedSize.width
    let fittingSize = contentView.view.sizeThatFits(
      CGSize(width: targetWidth, height: .greatestFiniteMagnitude)
    )

    contentView.view.frame = CGRect(
      origin: .zero,
      size: CGSize(width: bounds.width, height: fittingSize.height)
    )

    if fittingSize.height > 0 && abs(fittingSize.height - lastReportedHeight) > 0.5 {
      lastReportedHeight = fittingSize.height
      onContentSizeChange(["height": fittingSize.height])
    }
  }
}
