//
//  TabBarVC.swift
//  Paradise
//
//  Created by Omar Warrayat on 15/03/2021.
//

import UIKit

class TabBarVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 15, *) {
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.backgroundColor = .white
            tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.black]
            tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.lightGray]
            tabBar.standardAppearance = tabBarAppearance
            tabBar.scrollEdgeAppearance = tabBarAppearance
            
        } else {
            UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .selected)
            UITabBarItem.appearance().setTitleTextAttributes([.foregroundColor: UIColor.lightGray], for: .normal)
            tabBar.barTintColor = .white
        }
    }
    
    func appDelegate() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
       // print(item.title)
//        if item.title == "Favorite" || item.title == "المفضلة" {
//            
//            let defaults = UserDefaults.standard
//            let id = defaults.value(forKey: "id") as? String
//        
//            if id == nil {
//                self.appDelegate().notLogin()
//            }
//        }
        
    }
    
}
