//
//  KeepAlive.swift
//  Local Notifications Watch App
//
//  Created by Michael Harper on 11/9/23.
//

import Foundation
import HealthKit
import OSLog

class KeepAlive: NSObject {
    let healthStore = HKHealthStore()
    lazy var workoutConfiguration: HKWorkoutConfiguration = {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other
        configuration.locationType = .indoor
        return configuration
    }()
    
    var workoutSession: HKWorkoutSession?
    let logger = Logger(subsystem: "com.foreflight.watch.Local-Notifications", category: "KeepAlive")
}

extension KeepAlive {
    func keepAlive() async {
        logger.debug("keepAlive called")
        
        guard HKHealthStore.isHealthDataAvailable() else {
            logger.error("Health data is not available")
            return
        }
        
        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: workoutConfiguration)
            workoutSession?.delegate = self
            workoutSession?.startActivity(with: Date.now)
        } catch {
            logger.error("An error occurred creating a HKWorkoutSession. \(error.localizedDescription)")
        }
    }
    
    func concede() async {
        logger.debug("concede called")
        
        guard let workoutSession else { return }
        workoutSession.stopActivity(with: Date.now)
        let builder = workoutSession.associatedWorkoutBuilder()
        builder.discardWorkout()
        workoutSession.end()
        self.workoutSession = nil
    }
}

extension KeepAlive: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        logger.debug("workoutSession:didChangeTo:from: called")
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        logger.error("Creating a HKWorkoutSession failed. \(error.localizedDescription)")
    }
}
