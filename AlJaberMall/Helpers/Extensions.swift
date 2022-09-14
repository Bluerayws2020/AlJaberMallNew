//
//  Extensions.swift
//  Paradise
//
//  Created by Omar Warrayat on 28/12/2020.
//

import Foundation
import UIKit
import JGProgressHUD
import Alamofire
import MOLH

extension UIViewController {
    
    func image(fromLayer layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContext(layer.frame.size)
        
        layer.render(in: UIGraphicsGetCurrentContext()!)

        let outputImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return outputImage!
    }
    
    func addGradientForBtn(btn: UIButton, sizeForBtn: Int, height: Int) {
        btn.clipsToBounds = true
        
        let color1 = UIColor(red: 184/255, green: 22/255, blue: 43/255, alpha: 1)
        let color2 = UIColor(red: 229/255, green: 37/255, blue: 60/255, alpha: 1)
        
        let gradient: CAGradientLayer = CAGradientLayer()

        gradient.colors = [color1.cgColor, color2.cgColor]
        gradient.frame.size = btn.frame.size
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width - CGFloat(sizeForBtn), height: CGFloat(height))
        
        btn.layer.insertSublayer(gradient, at: 0)
    }
    
    func navColorBlack() {
        let color = UIColor(red: 27/255, green: 27/255, blue: 27/255, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = color
            appearance.titleTextAttributes = [.font:
            UIFont.boldSystemFont(ofSize: 20.0),
                                          .foregroundColor: UIColor.white]

            // Customizing our navigation bar
            navigationController?.navigationBar.tintColor = .white
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            
        } else {
            navigationController?.navigationBar.tintColor = .white
            //navigationController?.navigationBar.barTintColor = .white
            navigationController?.navigationBar.backgroundColor = color
            navigationController?.navigationBar.titleTextAttributes = [.font:
            UIFont.boldSystemFont(ofSize: 20.0),
                                          .foregroundColor: UIColor.white]
        }
    }
    
    func navColorWhite() {
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.titleTextAttributes = [.font:
            UIFont.boldSystemFont(ofSize: 20.0),
                                          .foregroundColor: UIColor.black]

            // Customizing our navigation bar
            navigationController?.navigationBar.tintColor = .black
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            
        } else {
            navigationController?.navigationBar.tintColor = .black
            navigationController?.navigationBar.backgroundColor = .white
            navigationController?.navigationBar.titleTextAttributes = [.font:
            UIFont.boldSystemFont(ofSize: 20.0),
                                          .foregroundColor: UIColor.black]
        }
    }
    
    func showMustLoginHud() {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Please login first".localized()
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 1.5, animated: true, completion: {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.notLogin()
        })
    }
    
    func showErrorHud(msg: String) {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = msg
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 1.5)
    }
    
    func showErrorHud(msg: String, hud: JGProgressHUD) {
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.textLabel.text = msg
        hud.dismiss(afterDelay: 1.5)
    }
    
    func showSuccessHud(msg: String, hud: JGProgressHUD) {
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.textLabel.text = msg
        hud.dismiss(afterDelay: 1.5)
    }
    
    func showSuccessHudAndOut(msg: String, hud: JGProgressHUD) {
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.textLabel.text = msg
        hud.dismiss(afterDelay: 1.5, animated: true, completion: {
            self.navigationController?.popViewController(animated: true)
        })
    }
    
    func internetError(hud: JGProgressHUD) {
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.textLabel.text = "Please check internet connection".localized()
        hud.dismiss(afterDelay: 1.5)
    }
    
    func serverError(hud: JGProgressHUD) {
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.textLabel.text = "Server Error".localized()
        hud.dismiss(afterDelay: 1.5)
    }
    
    func navigationText(title: String) {
        navigationItem.backBarButtonItem = UIBarButtonItem(
        title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.title = title
    }
    
}

extension String {
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: self, comment: "")
    }
}
