//
//  ContentView.swift
//  Local Notifications
//
//  Created by Michael Harper on 11/9/23.
//

import SwiftUI

struct ContentView: View {
    let notifier = Notifier.shared
    
    var body: some View {
        VStack {
            Button("Send Notification To Watch") {
                notifier.sendMessage()
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
