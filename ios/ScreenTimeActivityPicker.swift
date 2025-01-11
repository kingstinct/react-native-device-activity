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

  init() {}
}

struct InnerView: View {
  var body: some View {
    Color.clear
      .contentShape(Rectangle())
      .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}

@available(iOS 15.0, *)
struct Picker: View {
  @ObservedObject var model: ScreenTimeSelectAppsModel

  var body: some View {
    if #available(iOS 16.0, *) {
      FamilyActivityPicker(
        headerText: $model.headerText.wrappedValue,
        footerText: $model.footerText.wrappedValue,
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

@available(iOS 15.0, *)
struct ScreenTimeSelectAppsContentView: View {
  @ObservedObject var model: ScreenTimeSelectAppsModel
  var onRefreshAfterCrash: EventDispatcher

  var body: some View {
    if #available(iOS 16.0, *) {
      FamilyActivityPicker(
        headerText: $model.headerText.wrappedValue,
        footerText: $model.footerText.wrappedValue,
        selection: $model.activitySelection
      )
      .allowsHitTesting(false)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .edgesIgnoringSafeArea(.all)
    } else {
      // ... iOS 15 implementation ...
    }
  }
}
