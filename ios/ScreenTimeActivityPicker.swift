//
//  ScreenTimeActivityPicker.swift
//  ReactNativeDeviceActivity
//
//  Created by Robert Herber on 2023-07-05.
//

import Foundation
import FamilyControls
import SwiftUI

@available(iOS 15.0, *)
class ScreenTimeSelectAppsModel: ObservableObject {
    @Published var activitySelection = FamilyActivitySelection()

    init() { }
}

@available(iOS 15.0, *)
struct ScreenTimeSelectAppsContentView: View {
    @State private var pickerIsPresented = false
    @ObservedObject var model: ScreenTimeSelectAppsModel

    var body: some View {
      Color.clear
          .contentShape(Rectangle())
          .onTapGesture {
            pickerIsPresented = true
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .familyActivityPicker(
            /* only available on iOS 16, skipping for now
            headerText: "Header text",
            footerText: "Footer text",*/
              isPresented: $pickerIsPresented,
              selection: $model.activitySelection
          )
    }
}
