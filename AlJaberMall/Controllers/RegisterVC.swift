//
//  RegisterVC.swift
//  Paradise
//
//  Created by Omar Warrayat on 01/02/2021.
//

import UIKit
import Alamofire
import JGProgressHUD
import Photos
import MOLH

protocol RegisterDelegate {
    func loginSuccess()
}

extension RegisterDelegate {
    func loginSuccess() {}
}

class RegisterVC: UIViewController {

    @IBOutlet weak var firstNameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var phoneTxt: UITextField!
    @IBOutlet weak var passwordTxt: UITextField!
    @IBOutlet weak var confirmPasswordTxt: UITextField!
    @IBOutlet weak var createAccountBtn: UIButton!
    @IBOutlet weak var phoneNoView: UIView!
    @IBOutlet weak var navView: UIView!
    
    let genderPicker = UIPickerView()
    var pickerData: [String] = [String]()
    private var datePicker: UIDatePicker?
    var imagePicker = UIImagePickerController()
    var img: UIImage?
    var genderType = ""
    
    var RegisterDelegate: RegisterDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createAccountBtn.layer.cornerRadius = 7
        
        self.phoneNoView.layer.borderColor = UIColor.lightGray.cgColor
        self.phoneNoView.layer.cornerRadius = 5
        self.phoneNoView.layer.borderWidth = 1
        
    }
    
    @objc func dismissKeyboardd() {
        view.endEditing(true)
    }
    
    @IBAction func closeAction(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerAction(sender: UIButton) {
        if self.firstNameTxt.text != "" && self.emailTxt.text != "" && phoneTxt.text != "" && self.passwordTxt.text != "" && self.confirmPasswordTxt.text != "" && (self.passwordTxt.text == self.confirmPasswordTxt.text) {
            self.registerProcess()
            
        } else if self.firstNameTxt.text == "" {
            self.showErrorHud(msg: "Please enter full name".localized())
            
        } else if self.emailTxt.text == "" {
            self.showErrorHud(msg: "Please enter email".localized())
            
        } else if self.phoneTxt.text == "" {
            self.showErrorHud(msg: "Please enter phone".localized())
            
        } else if self.passwordTxt.text == "" {
            self.showErrorHud(msg: "Please enter password".localized())
            
        } else if self.confirmPasswordTxt.text == "" {
            self.showErrorHud(msg: "Please enter confirm password".localized())
            
        } else if self.passwordTxt.text != self.confirmPasswordTxt.text {
            self.showErrorHud(msg: "Please enter confirm password correctly".localized())
        }
    }
    
    func registerProcess() {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Please Wait".localized()
        hud.show(in: self.view)
        

        let registerUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.App_Ext + ServerConstants.REGISTER_URL)
        let registerParam: [String: String] = [
            "name": self.firstNameTxt.text!,
            "mail": self.emailTxt.text!,
            "pass": self.passwordTxt.text!,
            "phone": self.phoneTxt.text!,
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
//                                            defaults.value(forKey: "id")
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
                                      
                                        if let email = data["email"] as? String {
                                            defaults.setValue(email, forKey: "email")
                                        }
                                        
                                        defaults.synchronize()
                                        
                                        if let message = msg["message"] as? String {
                                            hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                                            hud.textLabel.text = message
                                            hud.dismiss(afterDelay: 1.5, animated: true, completion: {
                                                self.dismiss(animated: true, completion: {
                                                    self.RegisterDelegate?.loginSuccess()
                                                })
                                            })
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

}
