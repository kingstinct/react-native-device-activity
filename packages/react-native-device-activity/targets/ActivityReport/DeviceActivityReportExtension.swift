//
//  DeviceActivityReportExtension.swift
//  ActivityReport
//

import DeviceActivity
import ManagedSettings
import SwiftUI

@main
struct DeviceActivityReportUI: DeviceActivityReportExtension {
  var body: some DeviceActivityReportScene {
    PerAppUsageReport { appUsages in
      PerAppUsageView(appUsages: appUsages)
    }
  }
}

// MARK: - Context

extension DeviceActivityReport.Context {
  static let perAppUsage = Self("PerAppUsage")
}

// MARK: - Data Model

struct AppUsageInfo: Identifiable, Hashable {
  let id = UUID()
  let displayName: String
  let duration: TimeInterval
  let token: ApplicationToken?

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  static func == (lhs: AppUsageInfo, rhs: AppUsageInfo) -> Bool {
    lhs.id == rhs.id
  }
}

// MARK: - Report Scene

struct PerAppUsageReport: DeviceActivityReportScene {
  let context: DeviceActivityReport.Context = .perAppUsage
  let content: ([AppUsageInfo]) -> PerAppUsageView

  func makeConfiguration(
    representing data: DeviceActivityResults<DeviceActivityData>
  ) async -> [AppUsageInfo] {
    var appDurations: [String: (name: String, duration: TimeInterval, token: ApplicationToken?)] =
      [:]

    for await activityData in data {
      for await segment in activityData.activitySegments {
        for await category in segment.categories {
          for await app in category.applications {
            let name = app.application.localizedDisplayName ?? "Unknown"
            let key = name
            let existing = appDurations[key]
            appDurations[key] = (
              name: name,
              duration: (existing?.duration ?? 0) + app.totalActivityDuration,
              token: app.application.token
            )
          }
        }
      }
    }

    return appDurations.values
      .map { AppUsageInfo(displayName: $0.name, duration: $0.duration, token: $0.token) }
      .filter { $0.duration > 0 }
      .sorted { $0.duration > $1.duration }
  }
}

// MARK: - SwiftUI View

struct PerAppUsageView: View {
  let appUsages: [AppUsageInfo]

  var body: some View {
    if appUsages.isEmpty {
      Text("No usage data available")
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding()
    } else {
      VStack(spacing: 0) {
        ForEach(appUsages) { app in
          HStack {
            if let token = app.token {
              Label(token)
                .labelStyle(.iconOnly)
                .scaleEffect(1.5)
                .frame(width: 36, height: 36)
            }
            Text(app.displayName)
              .lineLimit(1)
            Spacer()
            Text(formatDuration(app.duration))
              .foregroundColor(.secondary)
              .monospacedDigit()
          }
          .padding(.horizontal)
          .padding(.vertical, 10)

          if app.id != appUsages.last?.id {
            Divider()
              .padding(.leading, 52)
          }
        }
      }
    }
  }

  private func formatDuration(_ duration: TimeInterval) -> String {
    let formatter = DateComponentsFormatter()
    formatter.allowedUnits = [.hour, .minute]
    formatter.unitsStyle = .abbreviated
    formatter.zeroFormattingBehavior = .dropAll
    if let formatted = formatter.string(from: duration) {
      return formatted
    }
    let minutes = Int(duration / 60)
    if minutes < 1 {
      return "<1m"
    }
    return "\(minutes)m"
  }
}
