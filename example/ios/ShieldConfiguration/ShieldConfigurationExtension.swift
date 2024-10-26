//
//  ShieldConfigurationExtension.swift
//  ShieldConfiguration
//
//  Created by Robert Herber on 2024-10-25.
//

import ManagedSettings
import ManagedSettingsUI
import UIKit

// Override the functions below to customize the shields used in various situations.
// The system provides a default appearance for any methods that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldConfigurationExtension: ShieldConfigurationDataSource {
    override func configuration(shielding application: Application) -> ShieldConfiguration {
        // Customize the shield as needed for applications.
      
        return ShieldConfiguration(
          backgroundBlurStyle: .dark,
          backgroundColor: UIColor.green,
          title: .init(text: "Title", color: .cyan),
          subtitle: .init(text: "Subtitle", color: .brown),
          primaryButtonLabel: .init(text: "Primary button", color: UIColor.blue),
          primaryButtonBackgroundColor: UIColor.yellow,
          secondaryButtonLabel: .init(text: "Secondary button", color: .blue)
        )
    }
    
    override func configuration(shielding application: Application, in category: ActivityCategory) -> ShieldConfiguration {
      
        // Customize the shield as needed for applications shielded because of their category.
      return ShieldConfiguration(
          backgroundBlurStyle: .dark,
          backgroundColor: UIColor.green,
          title: .init(text: "Title", color: .cyan),
          subtitle: .init(text: "Subtitle", color: .brown),
          primaryButtonLabel: .init(text: "Primary button", color: UIColor.blue),
          primaryButtonBackgroundColor: UIColor.yellow,
          secondaryButtonLabel: .init(text: "Secondary button", color: .blue)
        )
    }
    
    override func configuration(shielding webDomain: WebDomain) -> ShieldConfiguration {
        // Customize the shield as needed for web domains.

      return ShieldConfiguration(
          backgroundBlurStyle: .dark,
          backgroundColor: UIColor.green,
          title: .init(text: "Title", color: .cyan),
          subtitle: .init(text: "Subtitle", color: .brown),
          primaryButtonLabel: .init(text: "Primary button", color: UIColor.blue),
          primaryButtonBackgroundColor: UIColor.yellow,
          secondaryButtonLabel: .init(text: "Secondary button", color: .blue)
        )
    }
    
    override func configuration(shielding webDomain: WebDomain, in category: ActivityCategory) -> ShieldConfiguration {
        // Customize the shield as needed for web domains shielded because of their category.
      return ShieldConfiguration(
          backgroundBlurStyle: .dark,
          backgroundColor: UIColor.green,
          title: .init(text: "Title", color: .cyan),
          subtitle: .init(text: "Subtitle", color: .brown),
          primaryButtonLabel: .init(text: "Primary button", color: UIColor.blue),
          primaryButtonBackgroundColor: UIColor.yellow,
          secondaryButtonLabel: .init(text: "Secondary button", color: .blue)
        )
    }
}
