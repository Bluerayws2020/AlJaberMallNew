//
//  CategoriesVC.swift
//  Paradise
//
//  Created by Omar Warrayat on 21/01/2021.
//

import UIKit
import Alamofire
import JGProgressHUD
import MOLH
import CHTCollectionViewWaterfallLayout

class CategoriesVC: UIViewController, UITableViewDataSource, UITableViewDelegate  {

    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        <#code#>
//    }
    

    @IBOutlet weak var categorytable: UITableView!
    @IBOutlet weak var noDataLbl: UILabel!
    
    var categoryArray = [CategoryWithItemModel]()
    
    var count = 1
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
      
        self.noDataLbl.isHidden = true
        self.categorytable.delegate = self
        self.categorytable.dataSource = self
        self.categorytable.alwaysBounceVertical = true
        self.categorytable.register(UINib(nibName: "CategoryTableViewCell", bundle: nil), forCellReuseIdentifier: "CategoryTableViewCell")
       
        

  
        self.getCategories()
        
        self.categorytable.backgroundColor = .white
        self.categorytable.alwaysBounceVertical = true
        self.categorytable.bounces  = true
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.categorytable.addSubview(refreshControl)
        
        self.navigationText(title: "Categories".localized())
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navColorBlack()
    }
    
    @objc func didPullToRefresh() {
        self.getCategories()
    }
    

    
 
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "AllCategoryWithItemsVC") as! AllCategoryWithItemsVC
        vc.autoScroll = indexPath.row
        vc.categoryArray = self.categoryArray
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = self.categorytable.dequeueReusableCell(withIdentifier: "CategoryTableViewCell",for: indexPath) as? CategoryTableViewCell
        
        if cell == nil {
            let nib: [Any] = Bundle.main.loadNibNamed("CategoryTableViewCell", owner: self, options: nil)!
            cell = nib[0] as? CategoryTableViewCell
        }
        
        cell?.mainView.layer.cornerRadius = 10
        cell?.mainView.clipsToBounds = true
//        cell?.layer.borderWidth = 0
//        cell?.layer.shadowColor = UIColor.black.cgColor
//        cell?.layer.shadowOffset = CGSize(width: 0, height: 0)
//        cell?.layer.shadowRadius = 5
//        cell?.layer.shadowOpacity = 0.2
//        cell?.layer.masksToBounds = false
        cell?.layoutIfNeeded()
        
        cell?.titleLbl.text = self.categoryArray[indexPath.row].name
        
        cell?.loadingView.startAnimating()
        if let imgUrl = self.categoryArray[indexPath.row].image {
        let url = URL(string: imgUrl)
            cell?.img.sd_setImage(with: url, completed: { (image, error, cachType, url) in
                if error == nil {
                    cell?.img.image = image!
                    cell?.loadingView.stopAnimating()
                }
            })
           }
        
        return cell!
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
                                    self.categoryArray.removeAll()
                                    self.count = 1
                                    
                                    if let message = msg["message"] as? String {
                                        DispatchQueue.main.async {
                                            self.refreshControl?.endRefreshing()
                                            self.showSuccessHud(msg: message, hud: hud)
                                        }
                                    }
                                    
                                    if let data = jsonObj!["data"] as? [[String: Any]] {
                                        for item in data {
                                            let model = CategoryWithItemModel(data: item)
                                            self.categoryArray.append(model)
                                        }
                                        
                                        DispatchQueue.main.async {
                                            self.categorytable.reloadData()
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

}
