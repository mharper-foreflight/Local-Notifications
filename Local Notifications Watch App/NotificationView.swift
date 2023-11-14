//
//  NotificationView.swift
//  Local Notifications Watch App
//
//  Created by Michael Harper on 11/14/23.
//

import WatchKit
import SwiftUI
import UserNotifications

struct NotificationView: View {
    var message: String?
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.bubble")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(message ?? "Default message")
                .font(.caption)
        }
    }
}

#Preview {
    NotificationView(message: "You are here")
}

class NotificationController: WKUserNotificationHostingController<NotificationView> {
    var message: String?
    
    override var body: NotificationView {
        NotificationView(message: message)
    }
    
    override func didReceive(_ notification: UNNotification) {
        let notificationData = notification.request.content.userInfo as? [String: Any]
        message = notificationData?[LocalNotification.messageKey] as? String
    }
}
