//
//  Notifier.swift
//  Local Notifications
//
//  Created by Michael Harper on 11/9/23.
//

import Foundation
import WatchConnectivity
import OSLog

class Notifier: NSObject {
    static let shared = Notifier()
    
    let session: WCSession = .default
    let logger = Logger(subsystem: "com.foreflight.watch.Local-Notifications", category: "Notifier")
    
    private override init() {
        super.init()
        session.delegate = self
        session.activate()
    }
    
    func sendMessage() {
        if session.activationState == .activated {
            logger.info("Sending message to watch.")
            session.sendMessage(["message": "Test local notification on watch"], replyHandler: nil) {
                self.logger.error("Could not send message to watch. \($0.localizedDescription)")
            }
        } else {
            logger.error("Cannot send message to watch. WCSession is not active.")
        }
    }
}

extension Notifier: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error {
            logger.error("An error occured activating WCSession. \(error.localizedDescription)")
        } else {
            logger.info("WCSession activated with state. \(String(describing: activationState))")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        logger.info("WCSession became inactive.")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        logger.info("WCSession deactivated.")
    }
}

