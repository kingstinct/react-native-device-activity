//
//  ReactNativeDeviceActivityReportModule.swift
//  ReactNativeDeviceActivity
//

import ExpoModulesCore
import FamilyControls

@available(iOS 15.0, *)
public class ReactNativeDeviceActivityReportModule: Module {
    public func definition() -> ModuleDefinition {
        Name("ReactNativeDeviceActivityReportModule")

        View(DeviceActivityReportView.self) {
            Prop("context") { (view: DeviceActivityReportView, prop: String) in
                view.model.context = prop
            }

            Prop("from") { (view: DeviceActivityReportView, prop: Double?) in
                if let timestamp = prop {
                    view.model.from = Date(timeIntervalSince1970: timestamp / 1000)
                }
            }

            Prop("to") { (view: DeviceActivityReportView, prop: Double?) in
                if let timestamp = prop {
                    view.model.to = Date(timeIntervalSince1970: timestamp / 1000)
                }
            }

            Prop("segmentation") { (view: DeviceActivityReportView, prop: String?) in
                view.model.segmentation = prop ?? "daily"
            }

            Prop("familyActivitySelectionId") { (view: DeviceActivityReportView, prop: String?) in
                if let id = prop {
                    let selection = getFamilyActivitySelectionById(id: id)
                    if let selection = selection {
                        view.model.familyActivitySelection = selection
                        view.model.hasSelection = true
                    } else {
                        view.model.hasSelection = false
                    }
                } else {
                    view.model.hasSelection = false
                }
            }

            Prop("familyActivitySelection") { (view: DeviceActivityReportView, prop: String?) in
                if let selectionStr = prop {
                    let selection = deserializeFamilyActivitySelection(familyActivitySelectionStr: selectionStr)
                    view.model.familyActivitySelection = selection
                    view.model.hasSelection = true
                } else {
                    view.model.hasSelection = false
                }
            }
        }
    }
}
