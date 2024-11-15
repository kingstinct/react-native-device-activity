//
//  ShieldActionExtension.swift
//  ShieldAction
//
//  Created by Robert Herber on 2024-10-25.
//

import ManagedSettings
import UIKit

func openUrl(urlString: String){
  guard let url = URL(string: urlString) else {
    return //be safe
  }
  
  /*let context = NSExtensionContext()
  context.open(url) { success in
    
  }*/
  
  let application = UIApplication.value(forKeyPath: #keyPath(UIApplication.shared)) as! UIApplication

  if #available(iOS 10.0, *) {
      application.open(url, options: [:], completionHandler: nil)
  } else {
      application.openURL(url)
  }
}

func sendNotification(){
  let content = UNMutableNotificationContent()

  content.title = "Notification title"
  content.subtitle = "Notification subtitle"
  content.body = "Notification body"
  content.sound = UNNotificationSound.default

  // let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
  let request = UNNotificationRequest(identifier: "timerDone", content: content, trigger: nil)

  UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
}

// Override the functions below to customize the shield actions used in various situations.
// The system provides a default response for any functions that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldActionExtension: ShieldActionDelegate {
  override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
    // openUrl(urlString: "device-activity://")
    sendNotification()
    completionHandler(.defer)
  }
  
  override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
    // openUrl(urlString: "device-activity://")
    sendNotification()
    completionHandler(.defer)
  }
  
  override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
    // openUrl(urlString: "device-activity://")
    
    sendNotification()
    completionHandler(.defer)
  }
}
