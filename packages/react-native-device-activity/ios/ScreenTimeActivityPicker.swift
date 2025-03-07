//
//  ScreenTimeActivityPicker.swift
//  ReactNativeDeviceActivity
//
//  Created by Robert Herber on 2023-07-05.
//

import ExpoModulesCore
import FamilyControls
import Foundation
import SwiftUI

@available(iOS 15.0, *)
class ScreenTimeSelectAppsModel: ObservableObject {
  @Published var activitySelection = FamilyActivitySelection()

  @Published public var footerText: String?

  @Published public var headerText: String?

  // just used with "controlled" picker
  @Published public var activitySelectionId: String?

  @Published public var includeEntireCategory: Bool?

  init() {}
}

@available(iOS 15.0, *)
struct ActivityPicker: View {
  @ObservedObject var model: ScreenTimeSelectAppsModel

  var body: some View {
    if #available(iOS 16.0, *) {
      FamilyActivityPicker(
        headerText: model.headerText,
        footerText: model.footerText,
        selection: $model.activitySelection
      )
      .allowsHitTesting(false)
      .background(Color.clear)
    } else {
      FamilyActivityPicker(
        selection: $model.activitySelection
      )
      .allowsHitTesting(false)
      .background(Color.clear)
    }
  }
}
