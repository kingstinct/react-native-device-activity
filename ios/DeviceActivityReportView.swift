//
//  DeviceActivityReport.swift
//  Pods
//
//  Created by Robert Herber on 2024-11-12.
//

import Foundation
import FamilyControls
import DeviceActivity
import SwiftUI
import Combine
import ExpoModulesCore


@available(iOS 16.0, *)
class DeviceActivityReportViewModel: ObservableObject {
    @Published var familyActivitySelection = FamilyActivitySelection()
    
    @Published var devices = DeviceActivityFilter.Devices(Set<DeviceActivityData.Device.Model>())
    
    @Published var users: DeviceActivityFilter.Users? = .all
    
    @Published var context = "Total Activity"
    
    @Published var from = Date.distantPast
    
    @Published var to = Date.distantPast
    
    // Public property for setting the string value
    @Published var segmentation: String = "daily"
    
    // Computed property that converts to SegmentInterval
    var segment: DeviceActivityFilter.SegmentInterval {
        let interval = DateInterval(start: from, end: to)
    
        if(self.segmentation == "hourly"){
            return .hourly(during: interval)
        } else if (self.segmentation == "weekly"){
            return .weekly(during: interval)
        } else {
            return .daily(during: interval)
        }
    }
    
    init() { }
}


@available(iOS 16.0, *)
struct DeviceActivityReportUI: View {
    @ObservedObject var model: DeviceActivityReportViewModel
    
    var body: some View {
        DeviceActivityReport(
            DeviceActivityReport.Context(rawValue: model.context), // the context of your extension
          filter: model.users != nil ? DeviceActivityFilter(
            segment: model.segment,
            users: model.users!, // or .children
            devices: model.devices,
            applications: model.familyActivitySelection.applicationTokens,
            categories: model.familyActivitySelection.categoryTokens,
            webDomains: model.familyActivitySelection.webDomainTokens
            // you can decide which kind of data to show - apps, categories, and/or web domains
          ) : DeviceActivityFilter(
            segment: model.segment,
            devices: model.devices,
            applications: model.familyActivitySelection.applicationTokens,
            categories: model.familyActivitySelection.categoryTokens,
            webDomains: model.familyActivitySelection.webDomainTokens
            // you can decide which kind of data to show - apps, categories, and/or web domains
          )
        )
    }
}



// This view will be used as a native component. Make sure to inherit from `ExpoView`
// to apply the proper styling (e.g. border radius and shadows).
@available(iOS 16.0, *)
class DeviceActivityReportView: ExpoView {
    
    public let model = DeviceActivityReportViewModel()
    
    let contentView: UIHostingController<DeviceActivityReportUI>

    required init(appContext: AppContext? = nil) {
        contentView = UIHostingController(
            rootView: DeviceActivityReportUI(
                model: model
            )
        )
        
        super.init(appContext: appContext)
        
        clipsToBounds = true
        
        self.addSubview(contentView.view)
    }
    
    override func layoutSubviews() {
        contentView.view.frame = bounds
    }
    
}
