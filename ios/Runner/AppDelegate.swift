import Flutter
import UIKit
import Firebase
import GoogleMaps
import UserNotifications   // ✅ ADD THIS

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    FirebaseApp.configure()   // 🔥 This initializes Firebase
    GMSServices.provideAPIKey("AIzaSyAJsorrGKIgn2WoWP22VDCF1Utr8-Y1eqI")

    GeneratedPluginRegistrant.register(with: self)
    // ✅ VERY IMPORTANT: Set notification delegate
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // ✅ SHOW NOTIFICATION IN FOREGROUND
  @available(iOS 10.0, *)
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.alert, .badge, .sound])
  }

  // ✅ HANDLE NOTIFICATION TAP
  @available(iOS 10.0, *)
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    print("🔔 Notification tapped: \(response.notification.request.content.userInfo)")
    completionHandler()
  }
}