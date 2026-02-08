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

  @Published public var showNavigationBar: Bool = false

  var onDismissRequest: (() -> Void)?

  init() {}
}

@available(iOS 15.0, *)
struct ActivityPicker: View {
  @ObservedObject var model: ScreenTimeSelectAppsModel

  /// Local state used by the `.familyActivityPicker` modifier to drive
  /// its native sheet presentation.
  @State private var isPickerPresented = false

  private var resolvedHeaderText: String? {
    let trimmed = model.headerText?.trimmingCharacters(in: .whitespacesAndNewlines)
    return (trimmed?.isEmpty == false) ? trimmed : nil
  }

  private var resolvedFooterText: String? {
    let trimmed = model.footerText?.trimmingCharacters(in: .whitespacesAndNewlines)
    return (trimmed?.isEmpty == false) ? trimmed : nil
  }

  var body: some View {
    if model.showNavigationBar {
      // Use the `.familyActivityPicker(isPresented:selection:)` **modifier**
      // instead of the inline `FamilyActivityPicker` view.  The modifier
      // presents the picker as a native sheet with Cancel/Done in the nav bar.
      nativeSheetPresentation
    } else {
      pickerContent
    }
  }

  // MARK: - Native sheet (modifier-based) presentation

  @ViewBuilder
  private var nativeSheetPresentation: some View {
    if #available(iOS 16.0, *), resolvedHeaderText != nil || resolvedFooterText != nil {
      Color.clear
        .familyActivityPicker(
          headerText: resolvedHeaderText,
          footerText: resolvedFooterText,
          isPresented: $isPickerPresented,
          selection: $model.activitySelection
        )
        .onAppear { isPickerPresented = true }
        .onChange(of: isPickerPresented) { presented in
          if !presented { model.onDismissRequest?() }
        }
    } else {
      Color.clear
        .familyActivityPicker(
          isPresented: $isPickerPresented,
          selection: $model.activitySelection
        )
        .onAppear { isPickerPresented = true }
        .onChange(of: isPickerPresented) { presented in
          if !presented { model.onDismissRequest?() }
        }
    }
  }

  // MARK: - Inline (embedded) picker

  @ViewBuilder
  private var pickerContent: some View {
    if #available(iOS 16.0, *), resolvedHeaderText != nil || resolvedFooterText != nil {
      FamilyActivityPicker(
        headerText: resolvedHeaderText,
        footerText: resolvedFooterText,
        selection: $model.activitySelection
      )
    } else {
      FamilyActivityPicker(
        selection: $model.activitySelection
      )
    }
  }
}
