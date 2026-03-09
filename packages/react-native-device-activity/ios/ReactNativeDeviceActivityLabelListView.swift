import ExpoModulesCore
import FamilyControls
import SwiftUI
import UIKit

@available(iOS 15.2, *)
class ReactNativeDeviceActivityLabelListView: ExpoView {

  let model = ActivityLabelListModel()

  let contentView: UIHostingController<ActivityLabelList>

  required init(appContext: AppContext? = nil) {
    contentView = UIHostingController(
      rootView: ActivityLabelList(model: model)
    )

    super.init(appContext: appContext)

    clipsToBounds = true
    backgroundColor = .clear

    contentView.view.backgroundColor = .clear

    self.addSubview(contentView.view)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    contentView.view.frame = bounds

    // Report intrinsic size so RN can size this view to fit content
    let fittingSize = contentView.view.systemLayoutSizeFitting(
      CGSize(width: bounds.width, height: UIView.layoutFittingCompressedSize.height),
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: .fittingSizeLevel
    )
    if abs(fittingSize.height - bounds.height) > 1.0 && fittingSize.height > 0 {
      invalidateIntrinsicContentSize()
    }
  }

  override var intrinsicContentSize: CGSize {
    let fittingSize = contentView.view.systemLayoutSizeFitting(
      CGSize(
        width: bounds.width > 0 ? bounds.width : UIView.layoutFittingExpandedSize.width,
        height: UIView.layoutFittingCompressedSize.height),
      withHorizontalFittingPriority: .required,
      verticalFittingPriority: .fittingSizeLevel
    )
    return fittingSize
  }
}
