//
//  AboutVC.swift
//  Paradise
//
//  Created by Omar Warrayat on 07/03/2021.
//

import UIKit
import Alamofire
import JGProgressHUD
import MOLH

class AboutVC: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var bodyLbl: UILabel!
    @IBOutlet weak var textView: UIView!
    
    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.layer.cornerRadius = 15
        self.textView.layer.shadowColor = UIColor.black.cgColor
        self.textView.layer.shadowOpacity = 0.5
        
        self.bodyLbl.textAlignment = MOLHLanguage.isRTLLanguage() ? .right: .left
        
        self.navigationText(title: "Aboutus".localized())
        
        self.getAbout()
        
        self.scrollView.alwaysBounceVertical = true
        self.scrollView.bounces  = true
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.scrollView.addSubview(refreshControl)
    }
    
    @objc func didPullToRefresh() {
        self.getAbout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navColorBlack()
    }
    
    func getAbout() {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Please Wait".localized()
        hud.show(in: self.view)
        
        let aboutUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.App_Ext + ServerConstants.ABOUT_US)
        
        AF.request(aboutUrl!).response { (response) in
            if response.error == nil {
                do {
                    let jsonObj = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                    
                    if jsonObj != nil {
                        if let msg = jsonObj!["msg"] as? [String: Any] {
                            if let status = msg["status"] as? Int {
                                if status == 1 {
                                    if let message = msg["message"] as? String {
                                        DispatchQueue.main.async {
                                            self.refreshControl?.endRefreshing()
                                            self.showSuccessHud(msg: message, hud: hud)
                                        }
                                    }
                                    
                                    if let data = jsonObj!["data"] as? [String: Any] {
                                        if let title = data["title"] as? String {
                                            DispatchQueue.main.async {
                                                self.titleLbl.text = title
                                            }
                                        }
                                        
                                        if let body = data["body"] as? String {
                                            DispatchQueue.main.async {
                                                self.bodyLbl.text = body
                                            }
                                        }
                                    }
                                    
                                } else {
                                    if let message = msg["message"] as? String {
                                        DispatchQueue.main.async {
                                            self.refreshControl?.endRefreshing()
                                            self.showErrorHud(msg: message, hud: hud)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                } catch let err as NSError {
                    print("Error: \(err)")
                    self.refreshControl?.endRefreshing()
                    self.serverError(hud: hud)
                }
            } else {
                print("Error")
                self.refreshControl?.endRefreshing()
                self.internetError(hud: hud)
            }
        }
    }
    
}
