//
//  DeviceActivityReportView.swift
//  ReactNativeDeviceActivity
//

import Combine
import DeviceActivity
import ExpoModulesCore
import FamilyControls
import SwiftUI

// MARK: - View Model

@available(iOS 15.0, *)
class DeviceActivityReportViewModel: ObservableObject {
    @Published var familyActivitySelection = FamilyActivitySelection()
    @Published var hasSelection = false
    @Published var context = "PerAppUsage"
    @Published var from: Date = Calendar.current.startOfDay(for: Date())
    @Published var to: Date = Date()
    @Published var segmentation: String = "daily"

    @available(iOS 16.0, *)
    var segment: DeviceActivityFilter.SegmentInterval {
        let interval = DateInterval(start: from, end: to)
        switch segmentation {
        case "hourly":
            return .hourly(during: interval)
        case "weekly":
            return .weekly(during: interval)
        default:
            return .daily(during: interval)
        }
    }

    @available(iOS 16.0, *)
    var filter: DeviceActivityFilter {
        if hasSelection {
            return DeviceActivityFilter(
                segment: segment,
                users: .all,
                devices: .init([.iPhone]),
                applications: familyActivitySelection.applicationTokens,
                categories: familyActivitySelection.categoryTokens
            )
        } else {
            return DeviceActivityFilter(
                segment: segment,
                users: .all,
                devices: .init([.iPhone])
            )
        }
    }
}

// MARK: - SwiftUI Host

@available(iOS 16.0, *)
struct DeviceActivityReportHostView: View {
    @ObservedObject var model: DeviceActivityReportViewModel

    var body: some View {
        DeviceActivityReport(
            DeviceActivityReport.Context(rawValue: model.context),
            filter: model.filter
        )
    }
}

// MARK: - ExpoView

@available(iOS 15.0, *)
class DeviceActivityReportView: ExpoView {

    let model = DeviceActivityReportViewModel()
    private var contentView: UIViewController?

    required init(appContext: AppContext? = nil) {
        super.init(appContext: appContext)

        clipsToBounds = true
        backgroundColor = .clear

        if #available(iOS 16.0, *) {
            let hostingController = UIHostingController(
                rootView: DeviceActivityReportHostView(model: model)
            )
            hostingController.view.backgroundColor = .clear
            contentView = hostingController
            self.addSubview(hostingController.view)
        }
    }

    override func layoutSubviews() {
        contentView?.view.frame = bounds
    }
}
