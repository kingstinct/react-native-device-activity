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
    
    @Published public var footerText: String?
    
    @Published public var headerText: String?
    
    init() { }
}

struct InnerView: View {
    var body: some View {
        Color.clear
            .contentShape(Rectangle())
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


@available(iOS 15.0, *)
struct ScreenTimeSelectAppsContentView: View {
    @State private var pickerIsPresented = false
    @ObservedObject var model: ScreenTimeSelectAppsModel
    
    var body: some View {
        if #available(iOS 16.0, *) {
            InnerView()
                .onTapGesture {
                    pickerIsPresented = true
                }
                .familyActivityPicker(
                    headerText: $model.headerText.wrappedValue,
                    footerText: $model.footerText.wrappedValue,
                    isPresented: $pickerIsPresented,
                    selection: $model.activitySelection
                )
        }
        else {
            InnerView()
                .onTapGesture {
                    pickerIsPresented = true
                }
                .familyActivityPicker(
                    isPresented: $pickerIsPresented,
                    selection: $model.activitySelection
                )
        }
    }
}
