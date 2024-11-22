//
//  Utils.swift
//  Pods
//
//  Created by Robert Herber on 2024-11-07.
//

import Foundation
import ManagedSettings
import UIKit
import os
import FamilyControls

let appGroup = "group.ActivityMonitor"
let userDefaults = UserDefaults(suiteName: appGroup)

@available(iOS 14.0, *)
let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "react-native-device-activity")

@available(iOS 15.0, *)
struct SelectionWithActivityName {
  var selection: FamilyActivitySelection
  var activityName: String
}

@available(iOS 15.0, *)
let store = ManagedSettingsStore()

@available(iOS 15.0, *)
func getFamilyActivitySelectionToActivityNameMap() -> [SelectionWithActivityName?]{
  if let familyActivitySelectionToActivityNameMap = userDefaults?.dictionary(forKey: "familyActivitySelectionToActivityNameMap") {
    return familyActivitySelectionToActivityNameMap.map { (key: String, value: Any) in
      if let familyActivitySelectionStr = value as? String {
        let activitySelection = getActivitySelectionFromStr(familyActivitySelectionStr: familyActivitySelectionStr)
        
        return SelectionWithActivityName(selection: activitySelection, activityName: key)
      }
      return nil
    }
  }
  return []
}

@available(iOS 15.0, *)
func getPossibleActivityName(
    applicationToken: ApplicationToken?,
    webDomainToken: WebDomainToken?,
    categoryToken: ActivityCategoryToken?
) -> String? {
    let familyActivitySelectionToActivityNameMap = getFamilyActivitySelectionToActivityNameMap()
    
    let foundIt = familyActivitySelectionToActivityNameMap.first(where: { (mapping) in
        if let mapping = mapping {
            if let applicationToken = applicationToken {
                if(mapping.selection.applicationTokens.contains(applicationToken)){
                    return true
                }
            }
            
            if let webDomainToken = webDomainToken {
                if(mapping.selection.webDomainTokens.contains(webDomainToken)){
                    return true
                }
            }
            
            if let categoryToken = categoryToken {
                if(mapping.selection.categoryTokens.contains(categoryToken)){
                    return true
                }
            }
        }
        
        return false
    })
    
    return foundIt??.activityName
}

@available(iOS 15.0, *)
func getActivitySelectionFromStr(familyActivitySelectionStr: String) -> FamilyActivitySelection {
  var activitySelection = FamilyActivitySelection()
  
  logger.log("got base64")
  let decoder = JSONDecoder()
  let data = Data(base64Encoded: familyActivitySelectionStr)
  do {
    logger.log("decoding base64..")
    activitySelection = try decoder.decode(FamilyActivitySelection.self, from: data!)
    logger.log("decoded base64!")
  }
  catch {
    logger.log("decode error \(error.localizedDescription)")
  }
  
  return activitySelection
}

@available(iOS 15.0, *)
func unblockAllApps(){
    store.shield.applicationCategories = nil
    store.shield.webDomainCategories = nil

    store.shield.applications = nil
    store.shield.webDomains = nil
}

@available(iOS 15.0, *)
func blockAllApps(){
    store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.all(except: Set())
    store.shield.webDomainCategories = ShieldSettings.ActivityCategoryPolicy.all(except: Set())
}

@available(iOS 15.0, *)
func blockSelectedApps(activitySelection: FamilyActivitySelection){
    store.shield.applications = activitySelection.applicationTokens
    store.shield.webDomains = activitySelection.webDomainTokens
    store.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(activitySelection.categoryTokens, except: Set())
    store.shield.webDomainCategories = ShieldSettings.ActivityCategoryPolicy.specific(activitySelection.categoryTokens, except: Set())
}

@available(iOS 15.0, *)
func parseShieldActionResponse(_ action: Any?) -> ShieldActionResponse{

    if let actionResponseRaw = action as? Int {
        let actionResponse = ShieldActionResponse(rawValue: actionResponseRaw)
        return actionResponse ?? .none
    }

    return .none
}

func parseActions(_ actionsRaw: Any?) -> [Action]{
    if let actions = actionsRaw as? [[String: Any]] {
        return actions.map { action in
            if let actionType = action["type"] as? String {
                switch actionType {
                /*case "unblockSelf":
                    return Action.unblockSelf*/
                case "unblockAll":
                    return Action.unblockAll
                default:
                    return Action.unblockAll
                }
            }
            return Action.unblockAll
        }
    }
    return []
}

enum Action {
    case unblockAll
}

@available(iOS 15.0, *)
struct ShieldActionConfig {
    var response: ShieldActionResponse
    
    var actions: [Action]
}

@available(iOS 15.0, *)
func getShieldActionConfig(shieldAction: ShieldAction) -> ShieldActionConfig{
    let actionConfig = userDefaults?.dictionary(forKey: "shieldActionConfig")
    
    let shieldPrimaryActionResponse = parseShieldActionResponse(actionConfig?["primaryButtonActionResponse"])
    let shieldSecondaryActionResponse = parseShieldActionResponse(actionConfig?["secondaryButtonActionResponse"])
    let primaryActions = parseActions(actionConfig?["primaryButtonAction"])
    let secondaryActions = parseActions(actionConfig?["secondaryButtonAction"])
    
    return ShieldActionConfig(
        response: shieldAction == .primaryButtonPressed ? shieldPrimaryActionResponse : shieldSecondaryActionResponse,
        actions: shieldAction == .primaryButtonPressed ? primaryActions : secondaryActions
    )
}


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


@available(iOS 15.0, *)
func saveShieldActionConfig(primary: ShieldActionConfig, secondary: ShieldActionConfig) {
    userDefaults?.set([
        "primaryButtonActionResponse": primary.response.rawValue,
        "primaryButtonAction": primary.actions.map({ action in
            return ["type": "unblockAll"]
        }),
        "secondaryButtonActionResponse": secondary.response.rawValue,
        "secondaryButtonAction": secondary.actions.map({ action in
            return ["type": "unblockAll"]
        })
    ], forKey: "shieldActionConfig")
}

func persistToUserDefaults(activityName: String, callbackName: String, eventName: String? = nil){
  let now = (Date().timeIntervalSince1970 * 1000).rounded()
  let fullEventName = eventName == nil
    ? "DeviceActivityMonitorExtension#\(activityName)#\(callbackName)"
    : "DeviceActivityMonitorExtension#\(activityName)#\(callbackName)#\(eventName!)"
  userDefaults?.set(now, forKey: fullEventName)
}

func traverseDirectory(at path: String) {
    do {
        let files = try FileManager.default.contentsOfDirectory(atPath: path)
        
        for file in files {
            let fullPath = path + "/" + file
            var isDirectory: ObjCBool = false
            
            if FileManager.default.fileExists(atPath: fullPath, isDirectory: &isDirectory) {
                if isDirectory.boolValue {
                    print("\(fullPath) is a directory")
                    // Recursively traverse subdirectory
                    traverseDirectory(at: fullPath)
                } else if(fullPath.hasSuffix("png")) {
                    print("\(fullPath) is a file")
                }
            } else {
                print("\(fullPath) does not exist")
            }
        }
    } catch {
        print("Error traversing directory at path \(path): \(error.localizedDescription)")
    }
}

func getAppGroupDirectory() -> URL? {
    let fileManager = FileManager.default
    let container = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroup)
    return container
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

func loadImageFromBundle(assetName: String) -> UIImage? {
    // Get the main bundle
    let bundle = Bundle.main
  // Bundle.main.
    guard let fURL = Bundle.main.urls(forResourcesWithExtension: "png", subdirectory: ".") else { return nil }

  logger.info("Found \(fURL.count) png files in bundle")
  
  traverseDirectory(at: Bundle.main.bundlePath)
  
  for url in fURL {
    logger.info("url: \(url.lastPathComponent)")
  }
    
    // Construct the file URL for the asset
    guard let filePath = bundle.path(forResource: assetName, ofType: "png") else {
        print("Error: Asset not found in bundle: \(assetName).png")
        return nil
    }
    
    // Load image data
    guard let imageData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
        print("Error: Could not load data from \(filePath)")
        return nil
    }
    
    // Create UIImage from data
    return UIImage(data: imageData)
}

func loadImageFromFileSystem(filePath: String) -> UIImage? {
    let fileURL = URL(fileURLWithPath: filePath)
    
    // Load data from the file URL
    guard let imageData = try? Data(contentsOf: fileURL) else {
        print("Error: Could not load data from \(filePath)")
        return nil
    }
    
    // Create UIImage from the data
    return UIImage(data: imageData)
}

func loadImageFromRemoteURL(urlString: String, completion: @escaping (UIImage?) -> Void) {
    guard let url = URL(string: urlString) else {
        print("Error: Invalid URL string")
        completion(nil)
        return
    }
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        // Handle errors
        if let error = error {
            print("Error fetching image from URL: \(error)")
            completion(nil)
            return
        }
        
        // Validate data
        guard let imageData = data, let image = UIImage(data: imageData) else {
            print("Error: Invalid image data from \(urlString)")
            completion(nil)
            return
        }
        
        completion(image)
    }
    
    task.resume()
}

func loadImageFromRemoteURLSynchronously(urlString: String) -> UIImage? {
    guard let url = URL(string: urlString) else {
      logger.info("Error: Invalid URL string")
        return nil
    }
    
    var image: UIImage? = nil
    let semaphore = DispatchSemaphore(value: 0)
  
  logger.info("Getting image")
    
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        // Handle errors
        if let error = error {
          logger.info("Error fetching image: \(error)")
        }
      
        
        
        // Validate data
        if let imageData = data {
          logger.info("Got image")
            image = UIImage(data: imageData)
        }
        
        // Signal the semaphore to release the lock
        semaphore.signal()
    }
    
    task.resume()
    
    // Wait for the task to complete
    semaphore.wait()
    
    return image
}
