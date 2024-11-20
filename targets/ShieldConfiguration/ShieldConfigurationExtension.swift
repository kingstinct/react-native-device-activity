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

func convertBase64StringToImage (imageBase64String: String?) -> UIImage? {
  if let imageBase64String = imageBase64String {
    let imageData = Data(base64Encoded: imageBase64String)
    let image = UIImage(data: imageData!)
    return image
  }
  
  return nil
}

func replacePlaceholders(_ text: String, with placeholders: [String: String?]) -> String {
    let retVal = placeholders.reduce(text) { text, placeholder in
      text.replacingOccurrences(of: "{" + placeholder.key + "}", with: placeholder.value ?? placeholder.key)
    }
    
    return retVal
}

func buildLabel(text: String?, with color: UIColor?, placeholders: [String: String?]) -> ShieldConfiguration.Label? {
  if let text = text {
    let color = color ?? UIColor.label
    return .init(text: replacePlaceholders(text, with: placeholders), color: color)
  }
  
  return nil
}

func getShieldConfiguration(dict: [String:Any], placeholders: [String: String?]) -> ShieldConfiguration {
  logger.log("Calling getShieldConfiguration")
  
  let backgroundColor = getColor(color: dict["backgroundColor"] as? [String: Double])
  
  let title = dict["title"] as? String
  let titleColor = getColor(color: dict["titleColor"] as? [String: Double])
  
  let subtitle = dict["subtitle"] as? String
  let subtitleColor = getColor(color: dict["subtitleColor"] as? [String: Double])

  let primaryButtonLabel = dict["primaryButtonLabel"] as? String
  let primaryButtonLabelColor = getColor(color: dict["primaryButtonLabelColor"] as? [String: Double])
  let primaryButtonBackgroundColor = getColor(color: dict["primaryButtonBackgroundColor"] as? [String: Double])
  
  let secondaryButtonLabel = dict["secondaryButtonLabel"] as? String
  let secondaryButtonLabelColor = getColor(color: dict["secondaryButtonLabelColor"] as? [String: Double])
  
  let icon = loadImageFromBundle(assetName: "assets/kingstinct")
  
  logger.log("got everything")

  let shield = ShieldConfiguration(
    backgroundBlurStyle: dict["backgroundBlurStyle"] != nil ? UIBlurEffect.Style.init(rawValue: dict["backgroundBlurStyle"] as! Int) : nil,
    backgroundColor: backgroundColor,
    icon: icon,
    title: buildLabel(text: title, with: titleColor, placeholders: placeholders),
    subtitle: buildLabel(text: subtitle, with: subtitleColor, placeholders: placeholders),
    primaryButtonLabel: buildLabel(text: primaryButtonLabel, with: primaryButtonLabelColor, placeholders: placeholders),
    primaryButtonBackgroundColor: primaryButtonBackgroundColor,
    secondaryButtonLabel: buildLabel(text: secondaryButtonLabel, with: secondaryButtonLabelColor, placeholders: placeholders)
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

      let placeholders: [String : String?] = [
        "applicationOrDomainDisplayName": application.localizedDisplayName,
        "token": "\(application.token!.hashValue)",
        "tokenType": "application",
        "activityName": getPossibleActivityName(
          applicationToken: application.token,
          webDomainToken: nil,
          categoryToken: nil
        )
      ]
      
      if let dict = userDefaults?.dictionary(forKey: "shieldConfiguration") {
        return getShieldConfiguration(dict: dict, placeholders: placeholders)
      }
      
      return ShieldConfiguration()
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
      
      logger.log("shielding application category")

      let placeholders = [
        "applicationOrDomainDisplayName": application.localizedDisplayName,
        "token": "\(category.token!.hashValue)",
        "tokenType": "application_category",
        "activityName": getPossibleActivityName(
          applicationToken: application.token,
          webDomainToken: nil,
          categoryToken: category.token
        )
      ]
      
      if let dict = userDefaults?.dictionary(forKey: "shieldConfiguration") {
        return getShieldConfiguration(dict: dict, placeholders: placeholders)
      }
      
      return ShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
      logger.log("shielding web domain")

      let placeholders = [
        "applicationOrDomainDisplayName": webDomain.domain,
        "token": "\(webDomain.token!.hashValue)",
        "tokenType": "web_domain",
        "activityName": getPossibleActivityName(
          applicationToken: nil,
          webDomainToken: webDomain.token,
          categoryToken: nil
        )
      ]
      
      // Customize the shield as needed for web domains.
      if let dict = userDefaults?.dictionary(forKey: "shieldConfiguration") {
        return getShieldConfiguration(dict: dict, placeholders: placeholders)
      }
      
      return ShieldConfiguration()
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
      
      logger.log("shielding web domain category")

      let placeholders = [
        "applicationOrDomainDisplayName": webDomain.domain,
        "token": "\(category.token!.hashValue)",
        "tokenType": "web_domain_category",
        "activityName": getPossibleActivityName(
          applicationToken: nil,
          webDomainToken: webDomain.token,
          categoryToken: category.token
        )
      ]
      
      if let dict = userDefaults?.dictionary(forKey: "shieldConfiguration") {
        return getShieldConfiguration(dict: dict, placeholders: placeholders)
      }
      
      return ShieldConfiguration()
    }
}
