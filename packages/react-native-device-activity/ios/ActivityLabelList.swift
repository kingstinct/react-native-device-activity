//
//  ActivityLabelList.swift
//  ReactNativeDeviceActivity
//

import Combine
import ExpoModulesCore
import FamilyControls
import Foundation
import SwiftUI

@available(iOS 15.0, *)
class ActivityLabelListModel: ObservableObject {
  @Published var activitySelection = FamilyActivitySelection()
}

@available(iOS 15.0, *)
struct ActivityLabelList: View {
  @ObservedObject var model: ActivityLabelListModel

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      if #available(iOS 15.2, *) {
        ForEach(Array(model.activitySelection.applicationTokens), id: \.self) { token in
          Label(token)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
        }
        ForEach(Array(model.activitySelection.categoryTokens), id: \.self) { token in
          Label(token)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
        }
      }
    }
  }
}
