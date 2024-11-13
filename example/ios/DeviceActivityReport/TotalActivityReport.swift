//
//  TotalActivityReport.swift
//  DeviceActivityReport
//
//  Created by Robert Herber on 2024-11-10.
//

import DeviceActivity
import SwiftUI

extension DeviceActivityReport.Context {
  static let totalActivity = DeviceActivityReport.Context("Total Activity")
}

struct TotalActivityReport: DeviceActivityReportScene {
    // Define which context your scene will represent.
    let context: DeviceActivityReport.Context = .totalActivity
    
    // Define the custom configuration and the resulting view for this report.
    let content: (String) -> TotalActivityView
    
    func makeConfiguration(representing data: DeviceActivityResults<DeviceActivityData>) async -> String {
        // Reformat the data into a configuration that can be used to create
        // the report's view.
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.zeroFormattingBehavior = .dropAll
        
        let totalActivityDuration = await data.flatMap { $0.activitySegments }.reduce(0, {
            $0 + $1.totalActivityDuration
        })
      
      /* let names = data.flatMap { point in
        point.activitySegments.flatMap { segment in
          segment.categories.flatMap { category in
            category.applications.map { application in
              application.application.localizedDisplayName
            }
          }
        }
      } */
      
      return "\(String(describing: formatter.string(from: totalActivityDuration)))"
    }
}
