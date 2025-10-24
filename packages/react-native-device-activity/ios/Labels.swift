//
//  ScreenTimeActivityPicker.swift
//  ReactNativeDeviceActivity
//
//  Created by Robert Herber on 2023-07-05.
//

import ExpoModulesCore
import FamilyControls
import Foundation
import ManagedSettings
import SwiftUI

@available(iOS 15.2, *)
struct ActivityCategoryLabel: View {
  var token: ActivityCategoryToken

  var body: some View {
    Label(token)
  }
}

@available(iOS 15.2, *)
struct ApplicationLabel: View {
  var token: ApplicationToken?

  var body: some View {
    if let token = token {
      Label(token)
    }
  }
}

@available(iOS 15.2, *)
struct WebDomainLabel: View {
  var token: Token<WebDomain>?

  var body: some View {
    if let token = token {
      Label(token)
    }
  }
}

@available(iOS 15.2, *)
struct AnyTokenLabel: View {
  var token: Token<Any>?

  var body: some View {
    if let token = token {
      if let webDomainToken = token as? Token<WebDomain> {
        WebDomainLabel(token: webDomainToken)
      } else if let applicationToken = token as? Token<Application> {
        ApplicationLabel(token: applicationToken)
      } else if let activityCategoryToken = token as? Token<ActivityCategory> {
        ActivityCategoryLabel(token: activityCategoryToken)
      }
    }
  }
}

@available(iOS 15.2, *)
class WebDomainLabelView: ExpoView {
  private var _token: WebDomainToken?
  var token: WebDomainToken? {
    get { _token }
    set {
      _token = newValue
      contentView.rootView.token = newValue
    }
  }

  let contentView: UIHostingController<WebDomainLabel>

  required init(appContext: AppContext? = nil) {
    contentView = UIHostingController(
      rootView: WebDomainLabel(token: _token)
    )

    super.init(appContext: appContext)

    clipsToBounds = true
    backgroundColor = .clear
    isUserInteractionEnabled = false

    contentView.view.backgroundColor = .clear
    contentView.view.isUserInteractionEnabled = false

    self.addSubview(contentView.view)
  }

  override func layoutSubviews() {
    contentView.view.frame = bounds
  }
}
