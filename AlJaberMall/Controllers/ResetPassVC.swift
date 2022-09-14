//
//  ResetPassVC.swift
//  Zooney
//
//  Created by Omar Warrayat on 27/10/2021.
//

import UIKit
import WebKit

class ResetPassVC: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationText(title: "Reset Password".localized())
        
        let url = URL(string: ServerConstants.BASE_URL + ServerConstants.RESETURL)
        let request = URLRequest(url: url!)
        webView.load(request)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadWebView(_:)), for: .valueChanged)
        webView.scrollView.addSubview(refreshControl)
    }
    
    @objc func reloadWebView(_ sender: UIRefreshControl) {
        webView.reload()
        sender.endRefreshing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = false
        self.navColorWhite()
    }
    
}
