//
//  LoginVC.swift
//  Paradise
//
//  Created by Omar Warrayat on 05/01/2021.
//

import UIKit
import Alamofire
import JGProgressHUD
import MOLH

class LoginVC: UIViewController {
    
    @IBOutlet weak var userNameTxt: UITextField!
    @IBOutlet weak var passTxt: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var mainView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginBtn.layer.cornerRadius = 15
        let tab = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.mainView.addGestureRecognizer(tab)
        
        self.navigationText(title: "Login".localized())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        self.navColorWhite()
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func resetAction(sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ResetPassVC") as! ResetPassVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
//    func resetPassAction(email: String) {
//        let hud = JGProgressHUD(style: .light)
//        hud.textLabel.text = "Please Wait".localized()
//        hud.show(in: self.view)
//        let resetUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.USERS_EXT + ServerConstants.RESETURL)
//        let resetParam: [String: String] = [
//            "api_password": ServerConstants.API_PASSWORD,
//            "email": email,
//            "lang": MOLHLanguage.isRTLLanguage() ? "ar": "en"
//        ]
//
//        AF.request(resetUrl!, method: .post, parameters: resetParam).response { (response) in
//            if response.error == nil {
//                do {
//                    let jsonObj = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
//
//                    if jsonObj != nil {
//                        if let status = jsonObj!["status"] as? Bool {
//                            if status == true {
//                                if let msg = jsonObj!["msg"] as? String {
//                                    self.showSuccessHud(msg: msg, hud: hud)
//                                }
//                            } else {
//                                if let msg = jsonObj!["msg"] as? String {
//                                    self.showErrorHud(msg: msg, hud: hud)
//                                }
//                            }
//                        }
//                    }
//
//                } catch let err as NSError {
//                    print("Error: \(err)")
//                    self.internetError(hud: hud)
//                }
//            } else {
//                print("Error")
//                self.internetError(hud: hud)
//            }
//        }
//    }
    
    @IBAction func loginAction(sender: UIButton) {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Please Wait".localized()
        hud.show(in: self.view)
        
        let loginUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.App_Ext + ServerConstants.Login_Url)
        let loginParam: [String: String] = [
            "user": self.userNameTxt.text!,
            "password": self.passTxt.text!
        ]
        
        AF.request(loginUrl!, method: .post, parameters: loginParam).response { (response) in
            if response.error == nil {
                do {
                    let jsonObj = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                    
                    if jsonObj != nil {
                        if let msg = jsonObj!["msg"] as? [String: Any] {
                            if let status = msg["status"] as? Int {
                                if status == 1 {
                                    if let message = msg["message"] as? String {
                                        DispatchQueue.main.async {
                                            self.showSuccessHud(msg: message, hud: hud)
                                        }
                                    }
                                    
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
                                    }
                                    
                                    DispatchQueue.main.async {
                                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                                        appDelegate.isLogin()
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

}
