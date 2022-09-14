//
//  LoginTypeVC.swift
//  Paradise
//
//  Created by Omar Warrayat on 03/03/2021.
//

import UIKit
import GoogleSignIn
import Firebase
import Alamofire
import JGProgressHUD
import FacebookCore
import FacebookLogin
import MOLH

protocol LoginTypeDelegate {
    func loginSuccess()
}

extension LoginTypeDelegate {
    func loginSuccess() {}
}

class LoginTypeVC: UIViewController {
    
    enum Actions: Int {
        case email = 0
        case google = 1
        case facebook = 2
    }
    
    var LoginTypeDelegate: LoginTypeDelegate?
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var googleView: UIView!
    @IBOutlet weak var facebookView: UIView!
    @IBOutlet weak var navView: UIView!
    
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var googleLbl: UILabel!
    @IBOutlet weak var facebookLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        GIDSignIn.sharedInstance()?.delegate = self
//        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        navigationItem.backBarButtonItem = UIBarButtonItem(
        title: "", style: .plain, target: nil, action: nil)
        
        self.navigationText(title: "Log in".localized())
        
        self.setBorderView(view: emailView)
        self.setBorderView(view: googleView)
        self.setBorderView(view: facebookView)
        
        self.emailLbl.textAlignment = MOLHLanguage.isRTLLanguage() ? .right: .left
        self.googleLbl.textAlignment = MOLHLanguage.isRTLLanguage() ? .right: .left
        self.facebookLbl.textAlignment = MOLHLanguage.isRTLLanguage() ? .right: .left
        
        let navLeftBtn = UIBarButtonItem(title: "Cancel".localized(), style: .plain, target: self, action: #selector(self.cancelAction))
        
        self.navigationItem.leftBarButtonItem = navLeftBtn
        
    }
    
    @objc func cancelAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setBorderView(view: UIView) {
        view.layer.cornerRadius = 15
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
    }
    
    //MARK:Google SignIn Delegate
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        // myActivityIndicator.stopAnimating()
    }
    // Present a view that prompts the user to sign in with Google
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }

    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }

    //completed sign In
//    public func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
//
//        if (error == nil) {
//            // Perform any operations on signed in user here.
//            let image = user.profile.imageURL(withDimension: 120)?.absoluteString
//            //print(image)
//            let userId = user.userID!                  // For client-side use only!
//            print(userId)
//            let idToken = user.authentication.accessToken // Safe to send to the server
//            print("Tooooken")
//            print(idToken!)
//            let fullName = user.profile.name!
//            print(fullName)
//            //let givenName = user.profile.givenName
//            //print(givenName)
//            //let familyName = user.profile.familyName
//            //print(familyName)
//            let email = user.profile.email!
//            print(email)
//            self.socialAction(email: email, fullname: fullName)
//            // ...
//        } else {
//            print("\(error.localizedDescription)")
//        }
//    }
    
    func socialAction(email: String, fullname: String) {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Please Wait".localized()
        hud.show(in: self.view)
        

        let registerUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.App_Ext + ServerConstants.REGISTER_URL)
        let registerParam: [String: String] = [
            "name": fullname,
            "mail": email,
            "social": "1",
            "lang": MOLHLanguage.isRTLLanguage() ? "ar": "en"
        ]
        
        AF.request(registerUrl!, method: .post, parameters: registerParam).response { (response) in
            if response.error == nil {
                do {
                    let jsonObj = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                    
                    if jsonObj != nil {
                        if let msg = jsonObj!["msg"] as? [String: Any] {
                            if let status = msg["status"] as? Int {
                                if status == 1 {
                                    if let data = jsonObj!["data"] as? [String: Any] {
                                        let defaults = UserDefaults.standard
                                        
                                        if let id = data["id"] as? String {
                                            defaults.setValue(id, forKey: "id")
                                        }
                                        if let role = data["role"] as? String {
                                            defaults.setValue(role, forKey: "role")
                                        }
                                        if let user_name = data["user_name"] as? String {
                                            defaults.setValue(user_name, forKey: "user_name")
                                        }
                                        if let social = data["social"] as? String {
                                            defaults.setValue(social, forKey: "social")
                                        }
                                        if let user_picture = data["user_picture"] as? String {
                                            defaults.setValue(user_picture, forKey: "user_picture")
                                        }
                                        if let email = data["email"] as? String {
                                            defaults.setValue(email, forKey: "email")
                                        }
                                        
                                        defaults.synchronize()
                                        
                                        if let message = msg["message"] as? String {
                                            DispatchQueue.main.async {
                                                hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                                                hud.textLabel.text = message
                                                hud.dismiss(afterDelay: 1.5, animated: true, completion: {
                                                    self.dismiss(animated: true, completion: {
                                                        self.LoginTypeDelegate?.loginSuccess()
                                                    })
                                                })
                                            }
                                        }
                                        
                                    }
                                    
                                } else {
                                    if let message = msg["message"] as? String {
                                        DispatchQueue.main.async {
                                            self.showErrorHud(msg: message, hud: hud)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                } catch let err as NSError {
                    print("Error: \(err)")
                    self.serverError(hud: hud)
                }
            } else {
                print("Error")
                self.internetError(hud: hud)
            }
        }
        
    }
    
    func checkIfLoggedIn() -> Bool {
      let isTokenExist = AccessToken.current?.tokenString != nil
      let isTokenValid = !(AccessToken.current?.isExpired ?? true)
      return isTokenExist && isTokenValid
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navColorWhite()
        //self.navigationController?.navigationBar.isHidden = true
//        let x = checkIfLoggedIn()
//
//        if x == true {
//            LoginManager.init().logOut()
//        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func getFacebookInfo() {
        let request = GraphRequest(graphPath: "me", parameters: ["fields": "id,email,picture,name"])
        request.start { (connection, result, error) in
            print("Facebook Result")
            print(result)
            
            if let data = result as? [String: Any] {
                let email = data["email"] as? String
                let name = data["name"] as? String
                self.socialAction(email: email!, fullname: name!)
            }
        }
    }
    
    @IBAction func closeAction(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doActions(sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        if sender.tag == Actions.email.rawValue {
            let vc = storyBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else if sender.tag == Actions.google.rawValue {
//            GIDSignIn.sharedInstance()?.signIn()
            
        } else if sender.tag == Actions.facebook.rawValue {
            let loginManager = LoginManager()
            loginManager.logIn(permissions: [.email, .publicProfile], viewController: self) { (loginResult) in
                         switch loginResult {
                         case .failed(let error):
                             print(error)
                         case .cancelled:
                             print("User cancelled login.")
                         case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                             print("Logged in! \(grantedPermissions) \(declinedPermissions) \(accessToken)")
                            self.getFacebookInfo()
                         }
                     }
            
        }
    }
    
}
