//
//  AllCategoryWithItemsVC.swift
//  Paradise
//
//  Created by Omar Warrayat on 24/01/2021.
//

import UIKit
import Alamofire
import JGProgressHUD
import MOLH

class AllCategoryWithItemsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    var categoryArray = [CategoryWithItemModel]()
    
    var clearIndex = 0
    var firstTime = true
    
    var autoScroll: Int?
    
    @IBOutlet weak var categoriesCollection: UICollectionView!
    @IBOutlet weak var itemTable: UITableView!
    @IBOutlet weak var noDataLbl: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.noDataLbl.isHidden = true
        let collLayout = UICollectionViewFlowLayout()
        collLayout.sectionInset = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        collLayout.minimumLineSpacing = 30
        collLayout.minimumInteritemSpacing = 40
        collLayout.scrollDirection = .horizontal
        collLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
        self.categoriesCollection.delegate = self
        self.categoriesCollection.dataSource = self
        self.categoriesCollection.setCollectionViewLayout(collLayout, animated: false)
        self.categoriesCollection.register(UINib(nibName: "CategorySelectItemCell", bundle: Bundle.main), forCellWithReuseIdentifier: "CategorySelectItemCell")
        self.categoriesCollection.autoresizingMask = [.flexibleWidth]
        
        if MOLHLanguage.isRTLLanguage() == true {
            self.categoriesCollection.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.categoriesCollection.semanticContentAttribute = .forceLeftToRight
        }
        
        self.itemTable.backgroundColor = .white
        self.categoriesCollection.backgroundColor = .white
        
        self.navigationText(title: "All Categories".localized())
        
        if self.categoryArray.count == 0 {
            self.noDataLbl.isHidden = false
            
        } else {
            self.noDataLbl.isHidden = true
        }
        
        self.categoriesCollection.reloadData()
        self.categoriesCollection.setNeedsLayout()
        
        self.categoriesCollection.selectItem(at: NSIndexPath(item: self.autoScroll!, section: 0) as IndexPath, animated: true, scrollPosition: MOLHLanguage.isRTLLanguage() ? .right: .left)
        
        self.categoriesCollection.scrollToItem(at:IndexPath(item: self.autoScroll!, section: 0), at: MOLHLanguage.isRTLLanguage() ? .right: .left, animated: true)
        
        self.categoriesCollection.setNeedsLayout()
        
        self.clearIndex = self.autoScroll!
        self.autoScroll = 0
        
        self.itemTable.delegate = self
        self.itemTable.dataSource = self
        self.itemTable.register(UINib(nibName: "CategorySelectTableCell", bundle: nil), forCellReuseIdentifier: "CategorySelectTableCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navColorWhite()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if categoryArray.count == 0 {
            return 0
            
        } else {
            return categoryArray[self.clearIndex].items.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = self.itemTable.dequeueReusableCell(withIdentifier: "CategorySelectTableCell") as? CategorySelectTableCell
        
        if cell == nil {
            let nib: [Any] = Bundle.main.loadNibNamed("CategorySelectTableCell", owner: self, options: nil)!
            cell = nib[0] as? CategorySelectTableCell
        }
        
        let index = categoryArray[self.clearIndex].items[indexPath.row]
        
        cell?.nameLbl.text = index.title
        cell?.priceLbl.text = String(index.price!)
        
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 123
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
//        let vc = storyBoard.instantiateViewController(withIdentifier: "ItemDetailsVC") as! ItemDetailsVC
//        vc.itemDetail = categoryArray[self.clearIndex].items[indexPath.row]
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.categoriesCollection.cellForItem(at: indexPath) != nil else {
            return
        }
        
        let cell = self.categoriesCollection.cellForItem(at: indexPath) as! CategorySelectItemCell
        cell.isSelected = true
        cell.toggleSelected()
        self.clearIndex = indexPath.row
        self.itemTable.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        guard self.categoriesCollection.cellForItem(at: indexPath) != nil else {
            return
        }
        
        let cell = self.categoriesCollection.cellForItem(at: indexPath) as! CategorySelectItemCell
        cell.isSelected = false
        cell.toggleSelected()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = self.categoriesCollection.dequeueReusableCell(withReuseIdentifier: "CategorySelectItemCell", for: indexPath) as? CategorySelectItemCell
        
        if cell == nil {
            let nib: [Any] = Bundle.main.loadNibNamed("CategorySelectItemCell", owner: self, options: nil)!
            cell = nib[0] as? CategorySelectItemCell
        }
        
        if MOLHLanguage.isRTLLanguage() == true {
            //cell?.transform = CGAffineTransform(scaleX: -1, y: 1)
            cell?.categoryNameLbl.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
        cell?.categoryNameLbl.text = self.categoryArray[indexPath.row].name
        
        if indexPath.row == clearIndex {
            cell?.isSelected = true
            cell?.toggleSelected()
            
        } else {
            cell?.isSelected = false
            cell?.toggleSelected()
        }
        
        cell?.categoryNameLbl.sizeToFit()
        
        
        cell?.layoutIfNeeded()
        
        return cell!
    }
    
//    func getCategories() {
//        let hud = JGProgressHUD(style: .light)
//        hud.textLabel.text = "Please Wait".localized()
//        hud.show(in: self.view)
//
//        let defaults = UserDefaults.standard
//        let id = defaults.value(forKey: "id") as? Int
//
//        var categoryUrl: URL?
//        var categoryParam: [String: String]?
//
//        if id != nil {
//            categoryUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.CATEGORIES_EXT + ServerConstants.CATEGORIESWITHITEM_URL)
//            categoryParam = [
//                "api_password": ServerConstants.API_PASSWORD,
//                "user_id": String(id!),
//                "lang": MOLHLanguage.isRTLLanguage() ? "ar": "en"
//            ]
//
//        } else {
//            categoryUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.GUEST_EXT + ServerConstants.CATEGORIES_EXT + ServerConstants.CATEGORIESWITHITEM_URL)
//            categoryParam = [
//                "api_password": ServerConstants.API_PASSWORD,
//                "device_id": ServerConstants.MAC,
//                "lang": MOLHLanguage.isRTLLanguage() ? "ar": "en"
//            ]
//        }
//
//
//
//        AF.request(categoryUrl!, method: .post, parameters: categoryParam).response { (response) in
//            if response.error == nil {
//                do {
//                    let jsonObj = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
//
//                    if jsonObj != nil {
//                        if let status = jsonObj!["status"] as? Bool {
//                            if status == true {
//
//                                if let categories_with_items = jsonObj!["categories_with_items"] as? [[String: Any]] {
//                                    for item in categories_with_items {
//                                        let model = CategoryWithItemModel(data: item)
//                                        self.categoriesArray.append(model)
//                                    }
//
//                                    DispatchQueue.main.async {
//
//                                    }
//                                }
//                            } else {
//                                if let msg = jsonObj!["msg"] as? String {
//                                    DispatchQueue.main.async {
//                                        self.noDataLbl.isHidden = false
//                                        self.showErrorHud(msg: msg, hud: hud)
//                                    }
//                                }
//                            }
//
//                            DispatchQueue.main.async {
//                                self.refreshControl.endRefreshing()
//                            }
//                        }
//                    }
//
//                } catch let err as NSError {
//                    print("Error: \(err)")
//                    self.internetError(hud: hud)
//                    self.refreshControl.endRefreshing()
//                }
//            } else {
//                print("Error")
//                self.internetError(hud: hud)
//                self.refreshControl.endRefreshing()
//            }
//        }
//
//    }
    

}
