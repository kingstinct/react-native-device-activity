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
        .background(PresentedSheetBackgroundFixer())
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
        .background(PresentedSheetBackgroundFixer())
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

// MARK: - Sheet background fix

/// Finds the presented picker sheet's view hierarchy and sets the background
/// to `systemGroupedBackground` so the empty area below the list matches
/// the rest of the sheet. Uses a VC representable that observes when our
/// hosting controller presents a child.
@available(iOS 15.0, *)
struct PresentedSheetBackgroundFixer: UIViewControllerRepresentable {
  func makeUIViewController(context: Context) -> SheetBackgroundFixerController {
    SheetBackgroundFixerController()
  }

  func updateUIViewController(_ uiViewController: SheetBackgroundFixerController, context: Context) {}
}

@available(iOS 15.0, *)
class SheetBackgroundFixerController: UIViewController {
  private var observation: NSKeyValueObservation?

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    startObserving()
  }

  private func startObserving() {
    // Walk up to find the VC that will present the picker sheet.
    var candidate: UIViewController? = self
    while let c = candidate {
      // Observe `presentedViewController` so we catch it the moment the
      // picker sheet appears.
      observation = c.observe(
        \.presentedViewController, options: [.new]
      ) { [weak self] vc, _ in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
          self?.fixPresentedBackground(from: vc)
        }
      }
      // Also try immediately in case it's already presented.
      fixPresentedBackground(from: c)
      if c.presentedViewController != nil || c.parent == nil { break }
      candidate = c.parent
    }
  }

  private func fixPresentedBackground(from vc: UIViewController) {
    guard let presented = vc.presentedViewController else { return }
    applySystemBackground(to: presented.view)
    for child in presented.children {
      applySystemBackground(to: child.view)
    }
  }

  private func applySystemBackground(to view: UIView) {
    view.backgroundColor = .systemGroupedBackground
    // The picker nests views; walk a few levels deep.
    for sub in view.subviews {
      if sub.backgroundColor == .white || sub.backgroundColor == .systemBackground {
        sub.backgroundColor = .systemGroupedBackground
      }
    }
  }
}
