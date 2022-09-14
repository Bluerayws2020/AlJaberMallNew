//
//  LoginRegisterVC.swift
//  Paradise
//
//  Created by Omar Warrayat on 28/12/2020.
//

import UIKit

class LoginRegisterVC: UIViewController, LoginTypeDelegate, RegisterDelegate {
    
    @IBOutlet weak var guestBtn: UIButton!
    @IBOutlet weak var signInBtn: UIButton!
    @IBOutlet weak var createBtn: UIButton!
    
    enum Actions: Int {
        case guest = 0
        case signIn = 1
        case create = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.guestBtn.layer.cornerRadius = 30
        self.guestBtn.layer.borderWidth = 1
        self.guestBtn.layer.borderColor = UIColor.white.cgColor

        self.signInBtn.layer.cornerRadius = 30
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(loginSuccess), name: Notification.Name(nsNottificationLoginSuccess), object: nil)
    }
    
    @objc func loginSuccess() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.isLogin()
    }
    
    @IBAction func doAction(sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        
        if sender.tag == Actions.signIn.rawValue {
            let vc = storyBoard.instantiateViewController(withIdentifier: "LoginTypeVC") as! LoginTypeVC
            let vcNav = UINavigationController(rootViewController: vc)
            vc.LoginTypeDelegate = self
            vcNav.modalPresentationStyle = .fullScreen
            self.present(vcNav, animated: true, completion: nil)
            
        } else if sender.tag == Actions.create.rawValue {
            let vc = storyBoard.instantiateViewController(withIdentifier: "RegisterVC") as! RegisterVC
            vc.RegisterDelegate = self
            self.present(vc, animated: true, completion: nil)
            
        } else if sender.tag == Actions.guest.rawValue {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.isLogin()
        }
    }

}
