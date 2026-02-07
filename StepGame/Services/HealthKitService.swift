//
//  HealthKitService.swift
//  StepGame
//
//  Created by Arwa Alkadi on 27/01/2026.
//

import Foundation
import HealthKit
import Combine
import UIKit

@MainActor
final class HealthKitManager: ObservableObject {

    // MARK: - Properties
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

    /// ✅ Correct check for READ authorization
    func refreshAuthorizationState() async {
        guard HKHealthStore.isHealthDataAvailable(),
              let stepType else {
            isAuthorized = false
            return
        }

        do {
            let ok = try await hasReadAuthorization(for: stepType)
            isAuthorized = ok
        } catch {
            // لو صار خطأ اعتبريها غير مصرح
            isAuthorized = false
        }
    }

    private func hasReadAuthorization(for stepType: HKQuantityType) async throws -> Bool {
        try await withCheckedThrowingContinuation { cont in
            store.getRequestStatusForAuthorization(toShare: [], read: [stepType]) { status, error in
                if let error {
                    cont.resume(throwing: error)
                    return
                }

                // ✅ If request is unnecessary => already authorized (or user responded and we have access)
                // In practice for READ, this is the reliable signal.
                cont.resume(returning: status == .unnecessary)
            }
        }
    }

    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Steps Fetch (Range)

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

                let sum = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                cont.resume(returning: Int(sum))
            }

            self.store.execute(query)
        }
    }
}
