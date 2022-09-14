

import UIKit
import Firebase
import MOLH
import GoogleMaps
import GooglePlaces
import OneSignal
import GoogleSignIn
import FBSDKCoreKit
import JGProgressHUD

var nsNottificationLoginSuccess = "com.schedule.login"

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        ApplicationDelegate.shared.application(
                    application,
                    didFinishLaunchingWithOptions: launchOptions
                )
        
        MOLHLanguage.setDefaultLanguage("en")
        MOLH.shared.activate(true)
        
//        FirebaseApp.configure()
//        GIDSignIn.sharedInstance().clientID = "382339247895-i33kunrvqgmba7qoa6a292ph8hm5ec8m.apps.googleusercontent.com"
//        GIDSignIn.sharedInstance().delegate = self
//
        GMSServices.provideAPIKey("AIzaSyCDd-FZyU1V2WzYz_OtW6cdIgyqxZvn_cc")
        GMSPlacesClient.provideAPIKey("AIzaSyCDd-FZyU1V2WzYz_OtW6cdIgyqxZvn_cc")
        
        Thread.sleep(forTimeInterval: 2)
        
        // Remove this method to stop OneSignal Debugging
        OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)

        // OneSignal initialization
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId("cc8f527e-e21a-4b87-9572-adcc7079cdf5")

        // promptForPushNotifications will show the native iOS notification permission prompt.
        // We recommend removing the following code and instead using an In-App Message to prompt for notification permission (See step 8)
        OneSignal.promptForPushNotifications(userResponse: { accepted in
          print("User accepted notifications: \(accepted)")
        })
        
        self.checkLogin()
        
        return true
    }
    
    func application(
            _ app: UIApplication,
            open url: URL,
            options: [UIApplication.OpenURLOptionsKey : Any] = [:]
        ) -> Bool {

            ApplicationDelegate.shared.application(
                app,
                open: url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation]
            )

        }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//        print(user.profile.email)
    }
    
    func checkLogin() {
        let defaults = UserDefaults.standard
        let id = defaults.value(forKey: "id") as? String
        print(id)
        print("IDESA")
        if id != nil {
            self.isLogin()
            
        } else {
            self.notLogin()
        }
    }
    
    func isLogin() {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "tabNav")
        self.window?.rootViewController = vc
    }
    
    func notLogin() {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "LoginRegisterVC")
        self.window?.rootViewController = vc
    }
    
}

