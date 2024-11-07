//
//  ShieldConfigurationExtension.swift
//  ShieldConfiguration
//
//  Created by Robert Herber on 2024-10-25.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit
import os
import Foundation

let userDefaults = UserDefaults(suiteName: "group.ActivityMonitor")

let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "react-native-device-activity")

func getColor(color: [String: Double]?) -> UIColor? {
  if let color = color {
    let red = color["red"] ?? 0
    let green = color["green"] ?? 0
    let blue = color["blue"] ?? 0
    let alpha = color["alpha"] ?? 1
    
    return UIColor(
      red: red / 255,
      green: green / 255,
      blue: blue / 255,
      alpha: alpha
    )
  }
  
  return nil
}

func convertBase64StringToImage (imageBase64String: String?) -> UIImage? {
  if let imageBase64String = imageBase64String {
    let imageData = Data(base64Encoded: imageBase64String)
    let image = UIImage(data: imageData!)
    return image
  }
  
  return nil
}
func getShieldConfiguration() -> ShieldConfiguration {
  logger.log("Calling getShieldConfiguration")
  let dict = userDefaults?.object(forKey: "shieldConfiguration") as? [String:Any]
  
  let backgroundColor = getColor(color: dict?["backgroundColor"] as? [String: Double])
  
  let title = dict?["title"] as? String
  let titleColor = getColor(color: dict?["titleColor"] as? [String: Double]) ?? UIColor.label
  
  let subtitle = dict?["subtitle"] as? String
  let subtitleColor = getColor(color: dict?["subtitleColor"] as? [String: Double]) ?? UIColor.label

  let primaryButtonLabel = dict?["primaryButtonLabel"] as? String
  let primaryButtonLabelColor = getColor(color: dict?["primaryButtonLabelColor"] as? [String: Double]) ?? UIColor.label
  let primaryButtonBackgroundColor = getColor(color: dict?["primaryButtonBackgroundColor"] as? [String: Double])
  
  let secondaryButtonLabel = dict?["secondaryButtonLabel"] as? String
  let secondaryButtonColor = getColor(color: dict?["secondaryButtonColor"] as? [String: Double]) ?? UIColor.label
  
  let icon = convertBase64StringToImage(imageBase64String: dict?["icon"] as? String)
  
  logger.log("got everything")

  let shield = ShieldConfiguration(
    backgroundBlurStyle: dict?["backgroundBlurStyle"] != nil ? UIBlurEffect.Style.init(rawValue: dict!["backgroundBlurStyle"] as! Int) : nil,
    backgroundColor: backgroundColor,
    icon: icon,
    title: title != nil ? .init(text: title!, color: titleColor) : nil,
    subtitle: subtitle != nil ? .init(text: subtitle!, color: subtitleColor) : nil,
    primaryButtonLabel: primaryButtonLabel != nil ? .init(text: primaryButtonLabel!, color: primaryButtonLabelColor) : nil,
    primaryButtonBackgroundColor: primaryButtonBackgroundColor,
    secondaryButtonLabel: secondaryButtonLabel != nil ? .init(text: secondaryButtonLabel!, color: secondaryButtonColor) : nil
  )
  logger.log("shield initialized")
  
  return shield
}

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // Customize the shield as needed for applications.
      
      logger.log("shielding application")
      
      return getShieldConfiguration()
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
      
      logger.log("shielding application category")
      
      return getShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
      
      logger.log("shielding web domain")
        // Customize the shield as needed for web domains.
      return getShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
      
      logger.log("shielding web domain category")
      return getShieldConfiguration()
    }
}
