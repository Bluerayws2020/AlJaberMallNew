//
//  MenuVC.swift
//  Paradise
//
//  Created by Omar Warrayat on 07/03/2021.
//

import UIKit
import MOLH
import JGProgressHUD

class MenuVC: UIViewController {
    
    @IBOutlet weak var nameLbl: UILabel!
    
//    @IBOutlet weak var profileLbl: UILabel!
//    @IBOutlet weak var myOrdersLbl: UILabel!
//    @IBOutlet weak var aboutusLbl: UILabel!
//    @IBOutlet weak var contactusLbl: UILabel!
//    @IBOutlet weak var languageLbl: UILabel!
//    @IBOutlet weak var savedAddressLbl: UILabel!
//    @IBOutlet weak var logoutLbl: UILabel!
    
    @IBOutlet weak var arrowImg1: UIImageView!
    @IBOutlet weak var arrowImg2: UIImageView!
    @IBOutlet weak var arrowImg3: UIImageView!
    @IBOutlet weak var arrowImg4: UIImageView!
    @IBOutlet weak var arrowImg5: UIImageView!
    @IBOutlet weak var arrowImg6: UIImageView!
    @IBOutlet weak var arrowImg7: UIImageView!
    @IBOutlet weak var arrowImg8: UIImageView!
    @IBOutlet weak var arrowImg9: UIImageView!
    
    var dismissComplition: (() -> Void)?
    var languageComplition: (() -> Void)?
    
    enum Actions: Int {
        case myOrders = 0
        case favorites = 1
        case about = 2
        case setting = 3
        case notification = 4
        case lang = 5
        case contactUs = 6
        case address = 7
        case logout = 8
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        if let user_name = defaults.value(forKey: "user_name") as? String {
            self.nameLbl.text = user_name
        }
        
        if MOLHLanguage.isRTLLanguage() {
            self.arrowImg1.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.arrowImg2.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.arrowImg3.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.arrowImg4.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.arrowImg5.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.arrowImg6.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.arrowImg7.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.arrowImg8.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.arrowImg9.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @IBAction func doAction(sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let defaults = UserDefaults.standard
        let id = defaults.value(forKey: "id") as? String
        
        if sender.tag == Actions.setting.rawValue {
            if id != nil {
                let vc = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                self.navigationController?.pushViewController(vc, animated: true)
                
            } else {
                self.dismiss(animated: true, completion: self.dismissComplition)
            }
            
        }
        
//        else if sender.tag == Actions.aboutUs.rawValue {
//            let vc = storyBoard.instantiateViewController(withIdentifier: "WebVC") as! WebVC
//            vc.url = ServerConstants.ABOUT_US
//            vc.navigationText = "About Us".localized()
//            self.navigationController?.pushViewController(vc, animated: true)
//
//        }
        
        else if sender.tag == Actions.contactUs.rawValue {
            if id != nil {
                let vc = storyBoard.instantiateViewController(withIdentifier: "CallUSVC") as! CallUSVC
                self.navigationController?.pushViewController(vc, animated: true)
                
            } else {
                self.dismiss(animated: true, completion: self.dismissComplition)
            }
            
        } else if sender.tag == Actions.about.rawValue {
            let vc = storyBoard.instantiateViewController(withIdentifier: "AboutVC") as! AboutVC
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else if sender.tag == Actions.lang.rawValue {
            self.dismiss(animated: true, completion: self.languageComplition)
            
        } else if sender.tag == Actions.myOrders.rawValue {
            if id != nil {
                let vc = storyBoard.instantiateViewController(withIdentifier: "MyOrdersVC") as! MyOrdersVC
                self.navigationController?.pushViewController(vc, animated: true)
                
            } else {
                self.dismiss(animated: true, completion: self.dismissComplition)
            }
            
        } else if sender.tag == Actions.address.rawValue {
            if id != nil {
                let vc = storyBoard.instantiateViewController(withIdentifier: "AddLocationVC") as! AddLocationVC
                self.navigationController?.pushViewController(vc, animated: true)
                
            } else {
                self.dismiss(animated: true, completion: self.dismissComplition)
            }
            
        } else if sender.tag == Actions.logout.rawValue {
            let defaults = UserDefaults.standard
            defaults.setValue(nil, forKeyPath: "id")
            defaults.setValue(nil, forKeyPath: "role")
            defaults.setValue(nil, forKeyPath: "user_name")
            defaults.setValue(nil, forKeyPath: "user_picture")
            defaults.setValue(nil, forKeyPath: "email")
            defaults.synchronize()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.notLogin()
        }
    }
    
}
