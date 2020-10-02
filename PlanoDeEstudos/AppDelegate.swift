import UIKit
import UserNotifications

struct ActionIdentifier {
    static let confirm = "Confirm"
    static let cancel = "Cancel"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let center = UNUserNotificationCenter.current()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        center.delegate = self
        center.getNotificationSettings { (settings) in
            switch settings.authorizationStatus {
            case .notDetermined:
                self.center.requestAuthorization(options: [.alert, .sound, .badge, .carPlay]) { (authorized, error) in
                    if error == nil {
                        print(authorized)
                    }
                }
            default:
                break
            }
        }
        
        let confirmAction = UNNotificationAction(identifier: ActionIdentifier.confirm, title: "Já estudei 👍", options: [.foreground])
        let cancelAction = UNNotificationAction(identifier: ActionIdentifier.cancel, title: "Cancelar", options: [])
        let category = UNNotificationCategory(identifier: "Lembrete", actions: [confirmAction, cancelAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: [.customDismissAction])
        center.setNotificationCategories([category])
        
        return true
    }
}


//MARK: -
extension AppDelegate: UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let id = response.notification.request.identifier
        let title = response.notification.request.content.title
        
        print("ID: ", id, "Title:", title)
        
        switch response.actionIdentifier {
        case ActionIdentifier.confirm:
            print("Tocou em confirmar")
            
            NotificationCenter.default.post(name: NSNotification.Name("Confirmed"), object: nil, userInfo: ["id": id])
            
            break
        case ActionIdentifier.cancel:
            print("Cancelou")
            break
        case UNNotificationDefaultActionIdentifier:
            print("tocou na notificacao")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "Orange")
            window?.rootViewController?.show(vc, sender: nil)
            break
        case UNNotificationDismissActionIdentifier:
            print("dismissou a notificacao")
            break
        default:
            break
        }
        
        completionHandler()
    }
}
