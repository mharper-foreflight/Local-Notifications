# Local Notifications for watchOS

The purpose of this project is to demonstrate a 13-second delay when posting a local notification
from a watchOS app before the notification is presented to the user.

### Usage

I found that running the project in the Simulator ran into problems with the pairing between
the iPhone simulator and the Apple Watch simulator. Consequently, I strongly recommend running
this on an actual iPhone with a paired Apple Watch.

```
VERY IMPORTANT: Be sure to turn off any `Focus` that may be enabled on the iPhone/Apple Watch. Focus can
suppress the display of local notifications on the Apple Watch which negates the purpose
of this project.
```

1. Open the Xcode project `Local Notifications.xcodeproj`.
1. Under `Signing` for both targets, set the `Team` to something you can access.
1. Select the `Local Notifications` scheme and a physical iPhone.
1. Build & Run the scheme. Depending on the team you chose for signing, you may need to go
   to `Settings -> General -> VPN & Device Managment` and "trust" that team.
1. Upon launching the app on the iPhone, you should see a screen with a single button that says
   `Send Notification To Watch`.
1. Back in Xcode, select the `Local Notifications Watch App` scheme and the Apple Watch
   that is paired with the iPhone.
1. Build & Run the scheme on the Apple Watch. I find that this typically kills the app
   running on the iPhone.
1. You should now see a screen on the Apple Watch that says `Please put me in the background`.
   Do so by pressing the digital crown.
1. Relaunch the iPhone app either manually or using Xcode.
1. Tap `Send Notification To Watch`. You should immediately feel a haptic on your watch, and
   should see a request to allow the app to send notifications on the watch.
1. Tap `Allow` on your watch. You should now see the watch face. If not, press the digital
   crown until you see the watch face.
1. Back on the iPhone, tap `Send Notification To Watch` again. You should immediately feel
   a haptic played on your watch indicating that the message to create a notification has
   been received. Remain on the watch face.
1. 13 seconds after sending the notification/feeling the haptic, you should see a local
   notification displayed on the watch that says `Test local notification on watch`. You
   can either tap through on the notification to go back to the app or tap `Dismiss`. It
   doesn't matter because the point here is the 13-second delay after posting the local
   notification from the app.

### Discussion

Again, the purpose of this project is to demonstrate an unexpected but consistent 13-second delay
after creating and adding a local notification before the notification is finally presented
on the watch. The relevant code is here. As you can see, I add the notification request with a
time trigger interval of 0.1 seconds. And yet I consistently see the notification presented
13 seconds after adding the notification request.
```swift
        // Compose a local notification with the alert message.
        let content = UNMutableNotificationContent()
        content.title = message
        content.sound = .defaultCritical
        content.interruptionLevel = .timeSensitive
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // Schedule the notification request.
        do {
            _ = try await notificationCenter.add(request)
        } catch {
            logger.error("An error occurred scheduling the alert's local notification. \(error.localizedDescription)")
            return
        }

```
