//
//  HomeVC.swift
//  Paradise
//
//  Created by Omar Warrayat on 18/01/2021.
//

import UIKit
import Alamofire
import JGProgressHUD
import MOLH
import SideMenu

@available(iOS 13.0, *)
class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource, CategoryDelegate, CategorySelectedDelegate, CheckoutDelegate {
    
    @IBOutlet weak var homeTable: UITableView!
    @IBOutlet weak var noDataLbl: UILabel!
    
    var categoriesArray = [CategoryWithItemModel]()
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(
        title: "", style: .plain, target: nil, action: nil)
        self.noDataLbl.isHidden = true
        self.homeTable.delegate = self
        self.homeTable.dataSource = self
        self.homeTable.separatorStyle = .none
        //self.homeTable.register(UINib(nibName: "HomeNavCell", bundle: Bundle.main), forCellReuseIdentifier: "HomeNavCell")
        self.homeTable.register(UINib(nibName: "CategoriesCell", bundle: Bundle.main), forCellReuseIdentifier: "CategoriesCell")
        self.homeTable.register(UINib(nibName: "Categories11Cell", bundle: Bundle.main), forCellReuseIdentifier: "Categories11Cell")
        
        self.homeTable.alwaysBounceVertical = true
        self.homeTable.bounces  = true
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.homeTable.addSubview(refreshControl)
        
        self.homeTable.backgroundColor = .white
        
        self.setupSideMenu()
        
        self.getCategories()
        
        
    }
    
    @objc func didPullToRefresh() {
        self.categoriesArray.removeAll()
        self.homeTable.reloadData()
        self.getCategories()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.navigationBar.tintColor = .white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == 0 {
//            return 162
//
//        } else
        if indexPath.row == 0 {
            return 150
            
        } else {
            return 270
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.row == 0 {
//            var cell = self.homeTable.dequeueReusableCell(withIdentifier: "HomeNavCell", for: indexPath) as? HomeNavCell
//
//            if cell == nil {
//                let nib: [Any] = Bundle.main.loadNibNamed("HomeNavCell", owner: self, options: nil)!
//                cell = nib[0] as? HomeNavCell
//            }
//
//            return cell!
//
//
//
//        } else
        if indexPath.row == 0 {
            var cell = self.homeTable.dequeueReusableCell(withIdentifier: "Categories11Cell", for: indexPath) as? Categories11Cell
            
            if cell == nil {
                let nib: [Any] = Bundle.main.loadNibNamed("Categories11Cell", owner: self, options: nil)!
                cell = nib[0] as? Categories11Cell
            }
            
            cell?.CategorySelectedDelegate = self
            cell?.reloadData(categoriesArray: self.categoriesArray)
            
            return cell!
            
        } else {
            var cell = self.homeTable.dequeueReusableCell(withIdentifier: "CategoriesCell", for: indexPath) as? CategoriesCell
            
            cell?.CategoryDelegate = self
            
            if cell == nil {
                let nib: [Any] = Bundle.main.loadNibNamed("CategoriesCell", owner: self, options: nil)!
                cell = nib[0] as? CategoriesCell
            }
            
            
            cell?.titleLbl.text = self.categoriesArray[indexPath.row - 1].name
            
            cell?.reloadData(itemArray: self.categoriesArray[indexPath.row - 1].items)
            
            return cell!
        }
        
    }
    
    func getCategories() {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Please Wait".localized()
        hud.show(in: self.view)
        
        let defaults = UserDefaults.standard
        let id = defaults.value(forKey: "id") as? String ?? "0"
        
        let categoryUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.App_Ext + ServerConstants.CATEGORIESWITHITEM_URL)
        
        let categoryParam: [String: String] = [
            "uid": id
        ]
        
        AF.request(categoryUrl!, method: .post, parameters: categoryParam).response { (response) in
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
                                    
                                    if let data = jsonObj!["data"] as? [[String: Any]] {
                                        for item in data {
                                            let model = CategoryWithItemModel(data: item)
                                            self.categoriesArray.append(model)
                                        }
                                        
                                        DispatchQueue.main.async {
                                            self.homeTable.reloadData()
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
                    self.serverError(hud: hud)
                    self.refreshControl?.endRefreshing()
                }
            } else {
                print("Error")
                self.internetError(hud: hud)
                self.refreshControl?.endRefreshing()
            }
        }
        
    }
    
    func cellSelected(pid: String, actionType: Int, cellIndex: Int?, collection: UICollectionView?) {
        if actionType == 1 {
            let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc = storyBoard.instantiateViewController(withIdentifier: "ItemDetailsVC") as! ItemDetailsVC
            vc.pid = pid
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
        
//        else if actionType == 2 {
//            if item.favorite_status == 0 {
//                self.addToFavourite(item: item, completionHandler: { (result) in
//                    if result == true {
//                        let indexPath = IndexPath(row: cellIndex!, section: 0)
//                        let cell = collection!.cellForItem(at: indexPath) as! Categories2Cell
//                        cell.favouriteImg.image = UIImage(named: "favouriteFill")
//                        item.favorite_status = 1
//                    }
//                })
//
//            } else {
//                self.removeFavourite(item: item, completionHandler: { (result) in
//                    if result == true {
//                        let indexPath = IndexPath(row: cellIndex!, section: 0)
//                        let cell = collection!.cellForItem(at: indexPath) as! Categories2Cell
//                        cell.favouriteImg.image = UIImage(named: "favouriteEmpty")
//                        item.favorite_status = 0
//                    }
//                })
//            }
//
//        } else if actionType == 3 {
//            let indexPath = IndexPath(row: cellIndex!, section: 0)
//            let cell = collection!.cellForItem(at: indexPath) as! Categories2Cell
//
//            self.addToCart(itemId: item.id!, quantity: String(Int(cell.quantityLbl.text!)! + 1), completionHandler: { (result) in
//                if result == true {
//                    cell.quantityLbl.text = String(Int(cell.quantityLbl.text!)! + 1)
//                }
//            })
//
//        } else if actionType == 4 {
//            let indexPath = IndexPath(row: cellIndex!, section: 0)
//            let cell = collection!.cellForItem(at: indexPath) as! Categories2Cell
//
//            if cell.quantityLbl.text != "0" {
//                self.addToCart(itemId: item.id!, quantity: String(Int(cell.quantityLbl.text!)! - 1), completionHandler: { (result) in
//                    if result == true {
//                        cell.quantityLbl.text = String(Int(cell.quantityLbl.text!)! - 1)
//                    }
//                })
//            }
//
//            if cell.quantityLbl.text == "0" {
//                cell.addToCartView.isHidden = true
//            }
//        }
    }
    
    @IBAction func cartAction(sender: UIButton) {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "CartVC") as! CartVC
        vc.cartFrom = "1"
        vc.CheckoutDelegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func menuAction(sender: UIButton) {
        if MOLHLanguage.isRTLLanguage() {
            present(SideMenuManager.default.rightMenuNavigationController!, animated: true, completion: nil)
        } else {
            present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
        }
    }

    func CategoryCellSelected(CategoryIndex: Int, selectType: String) {
        if selectType == "search" {
            let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc = storyBoard.instantiateViewController(withIdentifier: "SearchVC") as! SearchVC
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
//            let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
//            let vc = storyBoard.instantiateViewController(withIdentifier: "ItemsByCategoryVC") as! ItemsByCategoryVC
//            vc.itemsArray = self.categoriesArray[CategoryIndex].items
//            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func checkoutSuccess(msg: String) {
        let hud = JGProgressHUD(style: .light)
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.textLabel.text = msg
        hud.show(in: self.view)
        hud.dismiss(afterDelay: 1.5)
    }
    
    func setupSideMenu() {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let menuController = storyBoard.instantiateViewController(withIdentifier: "MenuVC") as! MenuVC
        menuController.dismissComplition = {
            self.showMustLoginHud()
        }
        
        menuController.languageComplition = {
            let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc = storyBoard.instantiateViewController(withIdentifier: "LanguageVC") as! LanguageVC
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true, completion: nil)
        }
        
        let MenuNavigationController = SideMenuNavigationController(rootViewController: menuController)
        SideMenuManager.default.rightMenuNavigationController = nil
        SideMenuManager.default.leftMenuNavigationController = nil
        if MOLHLanguage.isRTLLanguage() {
            SideMenuManager.default.rightMenuNavigationController = MenuNavigationController
        } else {
            SideMenuManager.default.leftMenuNavigationController = MenuNavigationController
        }
        
         SideMenuManager.default.addPanGestureToPresent(toView: navigationController!.navigationBar)
         SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: navigationController!.navigationBar)
    }
    
}
