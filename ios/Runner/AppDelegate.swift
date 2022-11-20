import UIKit
import Flutter
import flutter_local_notifications
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
     FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
        FirebaseApp.configure()
        GeneratedPluginRegistrant.register(with: registry)
    }

    if #available(iOS 10.0, *) {
      application.applicationIconBadgeNumber = 0
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
      UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    if(!UserDefaults.standard.bool(forKey: "Notification")) {
    UIApplication.shared.cancelAllLocalNotifications()
    UserDefaults.standard.set(true, forKey: "Notification")
}

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  override func applicationDidEnterBackground(_ application: UIApplication){
   application.applicationIconBadgeNumber = 0
}
}
