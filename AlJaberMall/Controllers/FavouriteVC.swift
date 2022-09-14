//
//  FavouriteVC.swift
//  Paradise
//
//  Created by Omar Warrayat on 03/02/2021.
//

import UIKit
import MOLH
import Alamofire
import SDWebImage
import JGProgressHUD

class FavouriteVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var favouriteTable: UITableView!
    @IBOutlet weak var noFavoriteLbl: UILabel!
    
    var favouriteArray = [ItemsModel]()
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.favouriteTable.separatorStyle = .singleLine
        self.favouriteTable.delegate = self
        self.favouriteTable.dataSource = self
        self.favouriteTable.register(UINib(nibName: "CategorySelectTableCell", bundle: nil), forCellReuseIdentifier: "CategorySelectTableCell")
        
        let defaults = UserDefaults.standard
        let id = defaults.value(forKey: "id") as? String
        
        if id != nil {
            self.getFavourite()
        } else {
            let hud = JGProgressHUD(style: .light)
            hud.indicatorView = JGProgressHUDErrorIndicatorView()
            hud.textLabel.text = "Please login first".localized()
            hud.show(in: self.view)
            hud.dismiss(afterDelay: 1.5, animated: true, completion: {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.notLogin()
            })
        }
        
        self.noFavoriteLbl.isHidden = true
        
        self.navigationText(title: "Favorite".localized())
        
        self.favouriteTable.backgroundColor = .white
        
        self.favouriteTable.alwaysBounceVertical = true
        self.favouriteTable.bounces  = true
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.favouriteTable.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navColorBlack()
    }
    
    @objc func didPullToRefresh() {
        self.favouriteArray.removeAll()
        self.favouriteTable.reloadData()
        self.getFavourite()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouriteArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 123
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = self.favouriteTable.dequeueReusableCell(withIdentifier: "CategorySelectTableCell") as? CategorySelectTableCell
        
        if cell == nil {
            let nib: [Any] = Bundle.main.loadNibNamed("CategorySelectTableCell", owner: self, options: nil)!
            cell = nib[0] as? CategorySelectTableCell
        }
        
        let index = favouriteArray[indexPath.row]
        
        cell?.nameLbl.text = index.title
        cell?.priceLbl.text = String(index.price!)
        cell?.weightLbl.isHidden = true
        
        cell?.loadingView.startAnimating()
        if let imgUrl = index.images {
            let url = URL(string: ServerConstants.BASE_URL2 + imgUrl)
            cell?.img.sd_setImage(with: url, completed: { (image, error, cachType, url) in
                if error == nil {
                    cell?.img.image = image!
                    cell?.loadingView.stopAnimating()
                }
            })
           }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ItemDetailsVC") as! ItemDetailsVC
        vc.pid = self.favouriteArray[indexPath.row].pid
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteFav(index: indexPath.row)
        }
    }
    
    func deleteFav(index: Int) {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Please Wait".localized()
        hud.show(in: self.view)

        let defaults = UserDefaults.standard
        let id = defaults.value(forKey: "id") as! String

        let addFavouriteUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.App_Ext + ServerConstants.ADDFAVOURITE_URL)
        let addFavouriteParam: [String: String] = [
            "uid": id,
            "product_id": self.favouriteArray[index].pid!

        ]

        AF.request(addFavouriteUrl!, method: .post, parameters: addFavouriteParam).response { (response) in
            if response.error == nil {
                do {
                    let jsonObj = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]

                    if jsonObj != nil {
                        if let msg = jsonObj!["msg"] as? [String: Any] {
                            if let status = msg["status"] as? Int {
                                if status == 1 {
                                    if let message = msg["message"] as? String {
                                        DispatchQueue.main.async {
                                            self.showSuccessHud(msg: message, hud: hud)
                                            self.favouriteArray.remove(at: index)
                                            let indexPath = NSIndexPath(row: index, section: 0) as IndexPath
                                            self.favouriteTable.deleteRows(at: [indexPath], with: .fade)
                                            
                                            if self.favouriteArray.count == 0 {
                                                self.noFavoriteLbl.isHidden = false
                                            }
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
    
    func getFavourite() {
        self.noFavoriteLbl.isHidden = true
        
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Please Wait".localized()
        hud.show(in: self.view)
        
        let defaults = UserDefaults.standard
        let id = defaults.value(forKey: "id") as! String
        
        let favouriteUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.App_Ext + ServerConstants.FAVOURITE_URL)
        let favouriteParam: [String: String] = [
            "uid": id,
            "lang": MOLHLanguage.isRTLLanguage() ? "ar": "en"
        ]
        
        AF.request(favouriteUrl!, method: .post, parameters: favouriteParam).response { (response) in
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
                                            let model = ItemsModel(data: item)
                                            self.favouriteArray.append(model)
                                        }
                                        
                                        DispatchQueue.main.async {
                                            self.favouriteTable.reloadData()
                                            
                                            if self.favouriteArray.count == 0 {
                                                self.noFavoriteLbl.isHidden = false
                                            }
                                        }
                                    }
                                    
                                } else {
                                    if let message = msg["message"] as? String {
                                        DispatchQueue.main.async {
                                            self.refreshControl?.endRefreshing()
                                            self.noFavoriteLbl.isHidden = false
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
