//
//  HealthKitService.swift
//  StepGame
//
//  Created by Claude on 02/02/2026.
//

import Foundation
import HealthKit
import Combine

class HealthKitService: ObservableObject {
    private let healthStore = HKHealthStore()
    @Published var isAuthorized = false
    
    // Check if HealthKit is available on this device
    static func isHealthKitAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    // Request authorization to read step count
    func requestAuthorization() async throws {
        guard HKHealthStore.isHealthDataAvailable() else {
            throw HealthKitError.notAvailable
        }
        
        // Define the step count type
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            throw HealthKitError.dataTypeNotAvailable
        }
        
        // Request read permission for step count
        try await healthStore.requestAuthorization(toShare: [], read: [stepCountType])
        
        await MainActor.run {
            self.isAuthorized = true
        }
    }
    
    // Get today's step count
    func getTodaySteps() async throws -> Int {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            throw HealthKitError.dataTypeNotAvailable
        }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepCountType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                continuation.resume(returning: Int(steps))
            }
            
            healthStore.execute(query)
        }
    }
    
    // Get step count for a specific date
    func getSteps(for date: Date) async throws -> Int {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            throw HealthKitError.dataTypeNotAvailable
        }
        
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: endOfDay,
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepCountType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                continuation.resume(returning: Int(steps))
            }
            
            healthStore.execute(query)
        }
    }
    
    // Get step count for a date range
    func getSteps(from startDate: Date, to endDate: Date) async throws -> Int {
        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            throw HealthKitError.dataTypeNotAvailable
        }
        
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate,
            options: .strictStartDate
        )
        
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepCountType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let steps = result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0
                continuation.resume(returning: Int(steps))
            }
            
            healthStore.execute(query)
        }
    }
}

// Custom errors
enum HealthKitError: Error {
    case notAvailable
    case dataTypeNotAvailable
    case authorizationDenied
    
    var localizedDescription: String {
        switch self {
        case .notAvailable:
            return "HealthKit is not available on this device"
        case .dataTypeNotAvailable:
            return "Step count data type is not available"
        case .authorizationDenied:
            return "HealthKit authorization was denied"
        }
    }
}
