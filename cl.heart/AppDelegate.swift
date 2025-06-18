import UIKit
import RealmSwift
import SwiftyStoreKit
import ApphudSDK
import SVProgressHUD
import UserNotifications
import AppsFlyerLib
import AppTrackingTransparency
import AdSupport
import StoreKit


@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, AppsFlyerLibDelegate {
    
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        Apphud.setAttribution(data: ApphudAttributionData(rawData: conversionInfo), from: .appsFlyer, identifer: AppsFlyerLib.shared().getAppsFlyerUID(), callback: nil)
    }
    
    func onConversionDataFail(_ error: Error) {
        Apphud.setAttribution(data: ApphudAttributionData(rawData: ["error" : error.localizedDescription]), from: .appsFlyer, identifer: AppsFlyerLib.shared().getAppsFlyerUID(), callback: nil)


    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Apphud.submitPushNotificationsToken(token: deviceToken, callback: nil)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if Apphud.handlePushNotification(apsInfo: response.notification.request.content.userInfo) {
            
        } else {
            
        }
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if Apphud.handlePushNotification(apsInfo: notification.request.content.userInfo) {
            
        } else {
            
        }
        completionHandler([])
    }

    var window: UIWindow?
    
    func fetchIDFA() {
        if #available(iOS 14.5, *) {
            DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    guard status == .authorized else {return}
                    let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                    Apphud.setDeviceIdentifiers(idfa: idfa, idfv: UIDevice.current.identifierForVendor?.uuidString)
                }
            }
        }
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        
        Apphud.start(apiKey: "app_6zQ6SW8w8iBLcfMhzFpxNpWfwfHHDR")
        Apphud.setDeviceIdentifiers(idfa: nil, idfv: UIDevice.current.identifierForVendor?.uuidString)
        fetchIDFA()

        
        AppsFlyerLib.shared().appsFlyerDevKey = "ne89GdUxXsG9Jv9WSx6PCX"
        AppsFlyerLib.shared().appleAppID = "id\(appleId)"
        AppsFlyerLib.shared().start()
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        
        let config = Realm.Configuration(
                    schemaVersion: 3,
                    migrationBlock: { migration, oldSchemaVersion in
        })
        Realm.Configuration.defaultConfiguration = config
        let realm = try! Realm()
        if realm.object(ofType: Account.self, forPrimaryKey: "main") == nil {
            let user = Account()
            user.id = "main"
            user.onb = true
            try! realm.write {
                realm.add(user)
            }
        }
        
        


        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    let realm = try! Realm()
                    try! realm.write {
                        Account.m().isPro = true
                    }
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    break;
                case .failed, .purchasing, .deferred:
                    let realm = try! Realm()
                    try! realm.write {
                        Account.m().isPro = false
                    }
                }
            }
        }
        
        
        if  Account.m().isPro  {
            let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: autosubscribeKey)
            SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
                switch result {
                case .success(let receipt):
                    var subscriptionId: String? = nil
                    subsList.forEach { id in
                        let purchaseResult = SwiftyStoreKit.verifySubscription(
                            ofType: .autoRenewable,
                            productId: id,
                            inReceipt: receipt)
                        switch purchaseResult {
                        case .purchased(let info):
                            subscriptionId = id
                        case .expired(_):
                            break
                        case .notPurchased:
                            break
                        }
                    }


                    if subscriptionId == nil {
                        let realm = try! Realm()
                        try! realm.write {
                            Account.m().isPro = false
                        }
                    } else {
                        let realm = try! Realm()
                        try! realm.write {
                            Account.m().isPro = true
                        }
                    }
                case .error(let error):
                    let realm = try! Realm()
                    try! realm.write {
                        Account.m().isPro = false
                    }
                }
            }
        }
//        
        SVProgressHUD.setDefaultMaskType(.black)
        UNUserNotificationCenter.current().delegate = self


        let vc = LoadingData()
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.setNavigationBarHidden(true, animated: false)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window!.rootViewController = navigationController
        self.window!.makeKeyAndVisible()

        return true
    }

    

}



var autosubscribeKey = "853608c6634449fa8bc2273dd24f6451"
var subsListMoney: [String:String] = [:]
var subsListInfo: [String:SKProduct] = [:]

var subsList: [String] = ["com.heartrate.week.subs", "com.heartrate.week"]
let appleId = "6746779084"

var onbID = "com.heartrate.week.subs"
var mainID = "com.heartrate.week"




class Font {
    
    static func getFont(name: String, size: CGFloat) -> UIFont {
     return UIFont(name: "Inter-\(name)", size: size)!
    }
    
    
    static func regular(size: CGFloat) -> UIFont {
        return Font.getFont(name: "Regular", size: size)
    }
    static func italic(size: CGFloat) -> UIFont {
        return Font.getFont(name: "Italic", size: size)
    }
    static func thin(size: CGFloat) -> UIFont {
        return Font.getFont(name: "Regular_Thin", size: size)
    }
    static func extraLight(size: CGFloat) -> UIFont {
        return Font.getFont(name: "Regular_ExtraLight", size: size)
    }
    static func light(size: CGFloat) -> UIFont {
        return Font.getFont(name: "Regular_Light", size: size)
    }
    static func medium(size: CGFloat) -> UIFont {
        return Font.getFont(name: "Regular_Medium", size: size)
    }
    static func semibold(size: CGFloat) -> UIFont {
        return Font.getFont(name: "Regular_SemiBold", size: size)
    }
    static func bold(size: CGFloat) -> UIFont {
        return Font.getFont(name: "Regular_Bold", size: size)
    }
    static func extraBold(size: CGFloat) -> UIFont {
        return Font.getFont(name: "Regular_ExtraBold", size: size)
    }
    static func black(size: CGFloat) -> UIFont {
        return Font.getFont(name: "Regular_Black", size: size)
    }
    static func italic_Thin_Italic(size: CGFloat) -> UIFont {
        return Font.getFont(name: "Italic_Thin-Italic", size: size)
    }
    static func italic_ExtraLight_Italic(size: CGFloat) -> UIFont {
        return Font.getFont(name: "Italic_ExtraLight-Italic", size: size)
    }
    static func italic_Light_Italic(size: CGFloat) -> UIFont {
        return Font.getFont(name: "Italic_Light-Italic", size: size)
    }
    static func Italic_Medium_Italic(size: CGFloat) -> UIFont {
        return Font.getFont(name: "Italic_Medium-Italic", size: size)
    }
    static func italic_SemiBold(size: CGFloat) -> UIFont {
        return Font.getFont(name: "Italic_SemiBold-Italic", size: size)
    }
    
}





class Account: Object {
    @objc dynamic var id: String!
    @objc dynamic var onb: Bool = true
    @objc dynamic var isPro: Bool = false
    @objc dynamic var age: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var isKG: Bool = true
    @objc dynamic var isMale: Bool = true
    override static func primaryKey() -> String? {
        return "id"
    }
    
    
    static func m() -> Account {
        let realm = try! Realm()
        return realm.object(ofType: Account.self, forPrimaryKey: "main")!
    }
    
}

class Pulse: Object {
    @objc dynamic var id: String!
    @objc dynamic var date_created: Date = Date()
    @objc dynamic var HRV: Int = 0
    @objc dynamic var ai: String = ""
    
    let BPMLit = List<Double>()
    
    var BPM: Int {
        if BPMLit.isEmpty { return 0 }
        let average = BPMLit.reduce(0, +) / Double(BPMLit.count)
        return Int(average.rounded())
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
