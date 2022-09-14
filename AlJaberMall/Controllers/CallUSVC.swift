//
//  CallUSVC.swift
//  Robina
//
//  Created by Omar Warrayat on 23/06/2021.
//

import UIKit
import MOLH
import Alamofire
import JGProgressHUD

class CallUSVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var firstNameTxt: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var subjectTxt: UITextField!
    @IBOutlet weak var sendMessageTxt: UITextField!
    
    @IBOutlet weak var firstNameView: UIView!
    @IBOutlet weak var lastNameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var subjectView: UIView!
    @IBOutlet weak var sendMessageView: UIView!
    
    @IBOutlet weak var sendBtn: UIButton!
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Call US".localized()
        self.titleLbl.text = "Contact for any kind of information".localized()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(
        title: "", style: .plain, target: nil, action: nil)
        
        self.changeViewLayer(changeView: self.firstNameView)
        self.changeViewLayer(changeView: self.lastNameView)
        self.changeViewLayer(changeView: self.emailView)
        self.changeViewLayer(changeView: self.subjectView)
        self.changeViewLayer(changeView: self.sendMessageView)
        
        self.sendBtn.layer.cornerRadius = 8
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navColorBlack()
    }
    
    func changeViewLayer(changeView: UIView) {
        changeView.layer.cornerRadius = 5
        changeView.layer.shadowOpacity = 0.2
        changeView.layer.shadowColor = UIColor.black.cgColor
    }
    
    @IBAction func sendAction(sender: UIButton) {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Please Wait".localized()
        hud.show(in: self.view)
        
        let lang = MOLHLanguage.isRTLLanguage() ? "ar": "en"
        
        let sendUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.App_Ext + ServerConstants.ContactUs_URL)
        
        let defaults = UserDefaults.standard
        let id = defaults.value(forKey: "id") as! String
        
        let sendParam: [String: String] = [
            "uid": id,
            "lang": lang,
            "name": self.firstNameTxt.text! + " " + self.lastNameTxt.text!,
            "email": self.emailTxt.text!,
            "subject": self.subjectTxt.text!,
            "message": self.sendMessageTxt.text!
        ]
        
        AF.request(sendUrl!, method: .post, parameters: sendParam).response { (response) in
            if response.error == nil {
                do {
                    let jsonObj = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                    
                    if jsonObj != nil {
                        if let msg = jsonObj!["msg"] as? [String: Any] {
                            if let status = msg["status"] as? Int {
                                if status == 1 {
                                    if let message = msg["message"] as? String {
                                        DispatchQueue.main.async {
                                            self.showSuccessHudAndOut(msg: message, hud: hud)
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
