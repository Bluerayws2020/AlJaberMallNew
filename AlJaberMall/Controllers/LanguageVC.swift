//
//  LanguageVC.swift
//  Nasco
//
//  Created by Omar Warrayat on 7/2/20.
//  Copyright © 2020 Omar Warrayat. All rights reserved.
//

import UIKit
import MOLH

class LanguageVC: UIViewController {
    
    @IBOutlet weak var chooseView: UIView!
    @IBOutlet weak var englishCheckImg: UIImageView!
    @IBOutlet weak var arabicCheckImg: UIImageView!
    @IBOutlet weak var englishLbl: UILabel!
    @IBOutlet weak var arabicLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationText(title: "Language".localized())
        
        self.englishLbl.textAlignment = MOLHLanguage.isRTLLanguage() ? .right: .left
        self.arabicLbl.textAlignment = MOLHLanguage.isRTLLanguage() ? .right: .left
        
        self.chooseView.layer.cornerRadius = 10
        self.chooseView.clipsToBounds = true
        
        if MOLHLanguage.isRTLLanguage() == true {
            self.arabicCheckImg.image = UIImage(named: "check")
        } else {
            self.englishCheckImg.image = UIImage(named: "check")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navColorBlack()
    }
    
    @IBAction func cancelAction(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnArabicPressed(_ sender: UIButton) {
        MOLH.setLanguageTo("ar")
        MOLH.reset()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.isLogin()
    }
    
    @IBAction func btnEnglishPressed(_ sender: UIButton) {
        MOLH.setLanguageTo("en")
        MOLH.reset()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.isLogin()
    }
    

}
