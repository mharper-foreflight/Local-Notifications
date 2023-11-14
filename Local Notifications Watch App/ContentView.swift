//
//  ContentView.swift
//  Local Notifications Watch App
//
//  Created by Michael Harper on 11/9/23.
//

import SwiftUI
import UserNotifications
import WatchConnectivity
import OSLog

struct ContentView: View {
    let sessionDelegate = SessionDelegate()
    let logger = Logger(subsystem: "com.foreflight.watch.Local-Notifications", category: "ContentView")
    let life = KeepAlive()
    
    var body: some View {
        VStack {
            Image(systemName: "applewatch.and.arrow.forward")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Please put me in the background")
        }
        .padding()
        .onAppear {
            Task {
                await life.keepAlive()
            }
        }
    }
}

class SessionDelegate: NSObject {
    let session: WCSession = .default
    let logger = Logger(subsystem: "com.foreflight.watch.Local-Notifications.watchkitapp", category: "SessionDelegate")
    
    override init() {
        super.init()
        session.delegate = self
        session.activate()
    }
}

extension SessionDelegate: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error {
            logger.error("An error occured activating WCSession. \(error.localizedDescription)")
        } else {
            logger.info("WCSession activated with state. \(String(describing: activationState))")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        let message = (message["message"] ?? "Unknown") as! String
        logger.info("Received message '\(message)' on watch.")
        
        // Play haptic immediately upon receiving message.
        WKInterfaceDevice.current().play(.notification)

        Task {
            // Fire a local notification immediately. Observe that it has a delay of 13 seconds before being displayed.
            await LocalNotification(message: message).fire()
        }
    }
}

struct LocalNotification {
    static let messageKey = "message_key"
    static let categoryKey = "notification_delay_test"
    
    let message: String
    let logger = Logger(subsystem: "com.foreflight.watch.Local-Notifications.watchkitapp", category: "LocalNotification")

    func fire() async {
        let notificationCenter = UNUserNotificationCenter.current()
        let notificationSettings = await notificationCenter.notificationSettings()
        
        guard notificationSettings.authorizationStatus != .denied else { return }

        // Request user authorization for notifications if the request hasn't been made yet.
        if notificationSettings.authorizationStatus == .notDetermined {
            do {
                guard try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) else { return }
            } catch {
                logger.error("An error occurred requesting authorization for local notifications. \(error.localizedDescription)")
                return
            }
        }
           
        guard [.authorized, .provisional].contains(notificationSettings.authorizationStatus) else { return }
        
        // Compose a local notification with the alert message.
        let content = UNMutableNotificationContent()
        content.title = message
        content.sound = .defaultCritical
        content.interruptionLevel = .timeSensitive
        content.userInfo = [Self.messageKey: message]
        content.categoryIdentifier = Self.categoryKey
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // Schedule the notification request.
        do {
            _ = try await notificationCenter.add(request)
        } catch {
            logger.error("An error occurred scheduling the alert's local notification. \(error.localizedDescription)")
            return
        }
    }
}

#Preview {
    ContentView()
}
