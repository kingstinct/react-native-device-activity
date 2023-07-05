import SwiftUI
import ExpoModulesCore
import FamilyControls
import UIKit
import Combine

private let userDefaultsKey = "ScreenTimeSelection"

// This view will be used as a native component. Make sure to inherit from `ExpoView`
// to apply the proper styling (e.g. border radius and shadows).
@available(iOS 15.0, *)
class DeviceActivityModel {
  
  
  init(){
    self.model.activitySelection = self.savedSelection() ?? FamilyActivitySelection()
  }
  
  public let model = ScreenTimeSelectAppsModel()
  
  // Used to encode codable to UserDefaults
  private let encoder = PropertyListEncoder()

  // Used to decode codable from UserDefaults
  private let decoder = PropertyListDecoder()
  
  func saveSelection(selection: FamilyActivitySelection) {
    let defaults = UserDefaults.standard
    
    let encoded = try? encoder.encode(selection)

    defaults.set(
        encoded,
        forKey: userDefaultsKey
    )
  }
  
  func savedSelection() -> FamilyActivitySelection? {
      let defaults = UserDefaults.standard

      guard let data = defaults.data(forKey: userDefaultsKey) else {
          return nil
      }
    
      return try? decoder.decode(
          FamilyActivitySelection.self,
          from: data
      )
  }
  
  static var current = DeviceActivityModel()
}
