//
//  ShieldActionExtension.swift
//  ShieldAction
//
//  Created by Robert Herber on 2024-10-25.
//

import ManagedSettings

// Override the functions below to customize the shield actions used in various situations.
// The system provides a default response for any functions that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldActionExtension: ShieldActionDelegate {
  override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
    executeShieldActionConfig(shieldAction: action, completionHandler: completionHandler)
  }
  
  override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
    executeShieldActionConfig(shieldAction: action, completionHandler: completionHandler)
  }
  
  override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
    executeShieldActionConfig(shieldAction: action, completionHandler: completionHandler)
  }
}
