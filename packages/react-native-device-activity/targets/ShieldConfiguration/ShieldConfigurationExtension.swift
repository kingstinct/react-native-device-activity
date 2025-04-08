//
//  ShieldConfigurationExtension.swift
//  ShieldConfiguration
//
//  Created by Robert Herber on 2024-10-25.
//

import Foundation
import ManagedSettings
import ManagedSettingsUI
import UIKit
import os

func convertBase64StringToImage(imageBase64String: String?) -> UIImage? {
  if let imageBase64String = imageBase64String {
    let imageData = Data(base64Encoded: imageBase64String)
    let image = UIImage(data: imageData!)
    return image
  }

  return nil
}

func buildLabel(text: String?, with color: UIColor?, placeholders: [String: String?])
  -> ShieldConfiguration.Label? {
  if let text = text {
    let color = color ?? UIColor.label
    return .init(text: replacePlaceholders(text, with: placeholders), color: color)
  }

  return nil
}

func loadImageFromAppGroupDirectory(relativeFilePath: String) -> UIImage? {
  let appGroupDirectory = getAppGroupDirectory()

  let fileURL = appGroupDirectory!.appendingPathComponent(relativeFilePath)

  // Load the image data
  guard let imageData = try? Data(contentsOf: fileURL) else {
    print("Error: Could not load data from \(fileURL.path)")
    return nil
  }

  // Create and return the UIImage
  return UIImage(data: imageData)
}

func resolveIcon(dict: [String: Any]) -> UIImage? {
  let iconAppGroupRelativePath = dict["iconAppGroupRelativePath"] as? String
  let iconSystemName = dict["iconSystemName"] as? String

  var image: UIImage?

  if let iconSystemName = iconSystemName {
    image = UIImage(systemName: iconSystemName)
  }

  if let iconAppGroupRelativePath = iconAppGroupRelativePath {
    image = loadImageFromAppGroupDirectory(relativeFilePath: iconAppGroupRelativePath)
  }

  if let iconTint = getColor(color: dict["iconTint"] as? [String: Double]) {
    image?.withTintColor(iconTint)
  }

  return image
}

func buildShield(placeholders: [String: String?], config: [String: Any]?)
  -> ShieldConfiguration {

  if let appGroup = appGroup {
    logger.log("Calling getShieldConfiguration with appgroup: \(appGroup, privacy: .public)")
  } else {
    logger.log("Calling getShieldConfiguration without appgroup!")
  }

  CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)

  if let config = config {
    let backgroundColor = getColor(color: config["backgroundColor"] as? [String: Double])

    let title = config["title"] as? String
    let titleColor = getColor(color: config["titleColor"] as? [String: Double])

    let subtitle = config["subtitle"] as? String
    let subtitleColor = getColor(color: config["subtitleColor"] as? [String: Double])

    let primaryButtonLabel = config["primaryButtonLabel"] as? String
    let primaryButtonLabelColor = getColor(
      color: config["primaryButtonLabelColor"] as? [String: Double])
    let primaryButtonBackgroundColor = getColor(
      color: config["primaryButtonBackgroundColor"] as? [String: Double])

    let secondaryButtonLabel = config["secondaryButtonLabel"] as? String
    let secondaryButtonLabelColor = getColor(
      color: config["secondaryButtonLabelColor"] as? [String: Double]
    )

    let shield = ShieldConfiguration(
      backgroundBlurStyle: config["backgroundBlurStyle"] != nil
        ? (config["backgroundBlurStyle"] as? Int).flatMap(UIBlurEffect.Style.init) : nil,
      backgroundColor: backgroundColor,
      icon: resolveIcon(dict: config),
      title: buildLabel(text: title, with: titleColor, placeholders: placeholders),
      subtitle: buildLabel(text: subtitle, with: subtitleColor, placeholders: placeholders),
      primaryButtonLabel: buildLabel(
        text: primaryButtonLabel, with: primaryButtonLabelColor, placeholders: placeholders),
      primaryButtonBackgroundColor: primaryButtonBackgroundColor,
      secondaryButtonLabel: buildLabel(
        text: secondaryButtonLabel, with: secondaryButtonLabelColor, placeholders: placeholders)
    )
    logger.log("shield initialized")

    return shield
  }

  return ShieldConfiguration()
}

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
  override func configuration(shielding application: Application) -> ShieldConfiguration {
    // Customize the shield as needed for applications.

    let config = getActivitySelectionPrefixedConfigFromUserDefaults(
      keyPrefix: SHIELD_CONFIGURATION_FOR_SELECTION_PREFIX,
      fallbackKey: FALLBACK_SHIELD_CONFIGURATION_KEY,
      applicationToken: application.token
    )

    let placeholders: [String: String?] = [
      "applicationOrDomainDisplayName": application.localizedDisplayName,
      "token": "\(application.token!.hashValue)",
      "tokenType": "application",
      "familyActivitySelectionId": getPossibleFamilyActivitySelectionIds(
        applicationToken: application.token
      ).first?.id
    ]

    return buildShield(
      placeholders: placeholders,
      config: config
    )
  }

  override func configuration(shielding application: Application, in category: ActivityCategory)
    -> ShieldConfiguration {

    logger.log("shielding application category")

    let config = getActivitySelectionPrefixedConfigFromUserDefaults(
      keyPrefix: SHIELD_CONFIGURATION_FOR_SELECTION_PREFIX,
      fallbackKey: FALLBACK_SHIELD_CONFIGURATION_KEY,
      applicationToken: application.token,
      categoryToken: category.token
    )

    let placeholders = [
      "applicationOrDomainDisplayName": application.localizedDisplayName,
      "token": "\(category.token!.hashValue)",
      "tokenType": "application_category",
      "familyActivitySelectionId": getPossibleFamilyActivitySelectionIds(
        applicationToken: application.token,
        categoryToken: category.token
      ).first?.id
    ]

    return buildShield(
      placeholders: placeholders,
      config: config
    )
  }

  override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
    logger.log("shielding web domain")

    let config = getActivitySelectionPrefixedConfigFromUserDefaults(
      keyPrefix: SHIELD_CONFIGURATION_FOR_SELECTION_PREFIX,
      fallbackKey: FALLBACK_SHIELD_CONFIGURATION_KEY,
      webDomainToken: webDomain.token
    )

    let placeholders = [
      "applicationOrDomainDisplayName": webDomain.domain,
      "token": "\(webDomain.token!.hashValue)",
      "tokenType": "web_domain",
      "familyActivitySelectionId": getPossibleFamilyActivitySelectionIds(
        webDomainToken: webDomain.token
      ).first?.id
    ]

    return buildShield(
      placeholders: placeholders,
      config: config
    )
  }

  override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory)
    -> ShieldConfiguration {

    logger.log("shielding web domain category")

    let config = getActivitySelectionPrefixedConfigFromUserDefaults(
      keyPrefix: SHIELD_CONFIGURATION_FOR_SELECTION_PREFIX,
      fallbackKey: FALLBACK_SHIELD_CONFIGURATION_KEY,
      webDomainToken: webDomain.token,
      categoryToken: category.token
    )

    let placeholders = [
      "applicationOrDomainDisplayName": webDomain.domain,
      "token": "\(category.token!.hashValue)",
      "tokenType": "web_domain_category",
      "familyActivitySelectionId": getPossibleFamilyActivitySelectionIds(
        webDomainToken: webDomain.token,
        categoryToken: category.token
      ).first?.id
    ]

    return buildShield(
      placeholders: placeholders,
      config: config
    )
  }
}
