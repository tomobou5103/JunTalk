import UIKit
import Firebase
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    //Interval of Snooze
    private let repeatTimeArray:[Double] = [300.0,600.0,900.0]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
            
            //通知許可の取得
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound, .badge]){
                
                //complesionHandler
                (granted,error)in
                
                if error != nil {
                    print(error!)
                }
                
                if granted {
                    center.delegate = self
                }
            }
        //Tracking permission
        if #available(iOS 14, *) {
            switch ATTrackingManager.trackingAuthorizationStatus {
            case .authorized:
                print("Allow Tracking")
                print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
            case .denied:
                print("😭拒否")
            case .restricted:
                print("🥺制限")
            case .notDetermined:
                showRequestTrackingAuthorizationAlert()
            @unknown default:
                fatalError()
            }
        } else {// iOS14未満
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                print("Allow Tracking")
                print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
            } else {
                print("🥺制限")
            }
        }
        return true
    }
    //Alert表示
    private func showRequestTrackingAuthorizationAlert() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                switch status {
                case .authorized:
                    print("🎉")
                    //IDFA取得
                    print("IDFA: \(ASIdentifierManager.shared().advertisingIdentifier)")
                case .denied, .restricted, .notDetermined:
                    print("😭")
                @unknown default:
                    fatalError()
                }
            })
        }
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.getDeliveredNotifications { (notifications: [UNNotification]) in
            for notification in notifications {
                AlarmVC.shared.getAlarm(from: notification.request.identifier, identifier: "")
                NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)

            }
        }
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //アプリ起動中でもアラートと音で通知
        if #available(iOS 14.0, *) {
            completionHandler([[.banner, .list, .sound]])
        } else {
            completionHandler([[.alert, .sound]])
        }
        let uuid = notification.request.identifier
        AlarmVC.shared.getAlarm(from: uuid,identifier:"")
        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
    }
    func makeSnooze(response:UNNotificationResponse, repeatTime:Double){
        //通知がタップされた時の処理
        let identifier = response.actionIdentifier
    
        let voiceSound = identifier+"r.mp3"
        let sound:UNNotificationSound = UNNotificationSound.criticalSoundNamed(UNNotificationSoundName(rawValue: voiceSound))
        
        if identifier.contains("unk")&&identifier.contains("stop")==false{
            let snoozeAction = UNNotificationAction(
                identifier: identifier,
                title: "Snooze 5 Minutes",
                options: [.foreground]
            )
            let noAction = UNNotificationAction(
                identifier: "stop \(identifier)",
                title: "stop",
                options: [.foreground]
            )
            let alarmCategory = UNNotificationCategory(
                identifier: "alarmCategory",
                actions: [snoozeAction, noAction],
                intentIdentifiers: [],
                options: [])
            UNUserNotificationCenter.current().setNotificationCategories([alarmCategory])
            let content = UNMutableNotificationContent()
            content.title = "snooze"
            //音声ファイルを挿入
            content.sound = sound
            content.categoryIdentifier = "alarmCategory"
            
            let repeatId = String(repeatTime)
            let snoozeId = "Snooze"+identifier+repeatId
            
            //5分後に発火
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: repeatTime, repeats: false)
            let request = UNNotificationRequest(identifier: snoozeId, content: content, trigger: trigger)
            print("Snozoze作成\(identifier+repeatId)")
            //requesrをaddする
            UNUserNotificationCenter.current().add(request){ (error) in
                if let error = error{
                    print(error.localizedDescription)
                }
            }
        }else if identifier.contains("stop"){
            let repeatId = String(repeatTime)
            let comp:[String] = identifier.components(separatedBy:" ")
            let stopId = "Snooze\(comp[1])\(repeatId)"
            print("Snooze終了\(comp[1])\(repeatId)")
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [stopId])
            UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [stopId])
        }
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        for i in repeatTimeArray{
            makeSnooze(response: response, repeatTime: i)
        }
        let uuid = response.notification.request.identifier
        AlarmVC.shared.getAlarm(from: uuid, identifier:response.actionIdentifier)
        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil)
        completionHandler()
    }
}

