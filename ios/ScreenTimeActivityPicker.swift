//
//  ScreenTimeActivityPicker.swift
//  ReactNativeDeviceActivity
//
//  Created by Robert Herber on 2023-07-05.
//

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
    } else {
      FamilyActivityPicker(
        selection: $model.activitySelection
      )
      .allowsHitTesting(false)
    }
  }
}

@available(iOS 15.0, *)
struct ScreenTimeSelectAppsContentView: View {
  @State private var pickerIsPresented = false
  @ObservedObject var model: ScreenTimeSelectAppsModel
  @State private var shouldReload = false

  var body: some View {
    InnerView()
      .onTapGesture {
        print("Opening picker - resetting state")
        pickerIsPresented = true
      }
      .sheet(
        isPresented: $pickerIsPresented,
        onDismiss: {
          print("Sheet dismissed")
          pickerIsPresented = false
          if shouldReload {
            self.shouldReload = false
            DispatchQueue.main.async {
              pickerIsPresented = true
            }
          }
        },
        content: {
          ZStack {
            Button(
              role: .none,
              action: {
                print("Background tapped")
                pickerIsPresented = false
                self.shouldReload = true
              }
            ) {
              Text("View crashed - tap to reload")
            }
            .buttonStyle(PlainButtonStyle())

            Picker(model: model)
          }
        })
  }
}
