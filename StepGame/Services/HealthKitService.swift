//
//  HealthKitService.swift
//  StepGame
//

import Foundation
import HealthKit
import Combine
import UIKit

@MainActor
final class HealthKitManager: ObservableObject {

    private let store = HKHealthStore()

    @Published private(set) var isAuthorized: Bool = false

    private var stepType: HKQuantityType? {
        HKObjectType.quantityType(forIdentifier: .stepCount)
    }

    // MARK: - Authorization

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable(),
              let stepType else {
            isAuthorized = false
            return
        }

        store.requestAuthorization(toShare: [], read: [stepType]) { [weak self] _, _ in
            guard let self else { return }
            Task { @MainActor in
                await self.refreshAuthorizationState()
            }
        }
    }

    // MARK: - Refresh Authorization State
    /// Performs a lightweight read to verify access without treating all errors as denial
    func refreshAuthorizationState() async {
        guard HKHealthStore.isHealthDataAvailable(),
              let _ = stepType else {
            isAuthorized = false
            return
        }

        let now = Date()
        let start = now.addingTimeInterval(-5 * 60)

        do {
            _ = try await fetchSteps(from: start, to: now)
            isAuthorized = true
        } catch {
            if isAuthorizationError(error) {
                isAuthorized = false
            } else {
                isAuthorized = true
            }
        }
    }

    // MARK: - Authorization Error Detection
    private func isAuthorizationError(_ error: Error) -> Bool {
        let ns = error as NSError

        if ns.domain == HKErrorDomain,
           let code = HKError.Code(rawValue: ns.code) {
            switch code {
            case .errorAuthorizationDenied,
                 .errorAuthorizationNotDetermined:
                return true
            default:
                return false
            }
        }

        return false
    }

    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Steps Fetch

    func fetchSteps(from startDate: Date, to endDate: Date) async throws -> Int {
        guard HKHealthStore.isHealthDataAvailable(),
              let stepType else { return 0 }

        let clampedEnd = max(endDate, startDate)

        return try await withCheckedThrowingContinuation { cont in
            let predicate = HKQuery.predicateForSamples(
                withStart: startDate,
                end: clampedEnd,
                options: .strictStartDate
            )

            let query = HKStatisticsQuery(
                quantityType: stepType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error {
                    cont.resume(throwing: error)
                    return
                }

                // MARK: - Cumulative Step Count
                let sum = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                cont.resume(returning: Int(sum))
            }

            self.store.execute(query)
        }
    }
}
