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
  var familyActivitySelectionId: String?
  private var cancellable: AnyCancellable?

  func startObserving() {
    cancellable = NotificationCenter.default
      .publisher(for: UserDefaults.didChangeNotification)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        self?.refreshSelection()
      }
  }

  func refreshSelection() {
    guard let id = familyActivitySelectionId else { return }
    if let selection = getFamilyActivitySelectionById(id: id) {
      activitySelection = selection
    } else {
      activitySelection = FamilyActivitySelection()
    }
  }

  deinit {
    cancellable?.cancel()
  }
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
