//
//  DealsVC.swift
//  Paradise
//
//  Created by Omar Warrayat on 03/02/2021.
//

import UIKit
import MOLH
import Alamofire
import SDWebImage
import JGProgressHUD

class DealsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var dealCollection: UICollectionView!
    @IBOutlet weak var noDataLbl: UILabel!
    
    var dealArray = [ItemsModel]()
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noDataLbl.isHidden = true
        self.dealCollection.delegate = self
        self.dealCollection.dataSource = self
        
//        if MOLHLanguage.isRTLLanguage() == true {
//            self.cellCollection.transform = CGAffineTransform(scaleX: -1, y: 1)
//            self.cellCollection.semanticContentAttribute = .forceLeftToRight
//        }
        
        let collLayout = UICollectionViewFlowLayout()
        let width = (UIScreen.main.bounds.width - 30) / 3
        //self.categoryCollectionHeight.constant = width * 2 + 50
        collLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        collLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        collLayout.itemSize = CGSize(width: width, height: 205)
        
        dealCollection.backgroundColor = .clear
        dealCollection.setCollectionViewLayout(collLayout, animated: false)
        
        self.dealCollection.register(UINib(nibName: "Categories2Cell", bundle: Bundle.main), forCellWithReuseIdentifier: "Categories2Cell")
        
        self.navigationText(title: "Deals".localized())
        
        self.dealCollection.backgroundColor = .white
        
        self.dealCollection.alwaysBounceVertical = true
        self.dealCollection.bounces  = true
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.dealCollection.addSubview(refreshControl)
        
        self.getDeals()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navColorBlack()
    }
    
    @objc func didPullToRefresh() {
        self.dealArray.removeAll()
        self.dealCollection.reloadData()
        self.getDeals()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dealArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ItemDetailsVC") as! ItemDetailsVC
        vc.pid = self.dealArray[indexPath.row].pid
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = self.dealCollection.dequeueReusableCell(withReuseIdentifier: "Categories2Cell", for: indexPath) as? Categories2Cell
        
        if cell == nil {
            let nib: [Any] = Bundle.main.loadNibNamed("Categories2Cell", owner: self, options: nil)!
            cell = nib[0] as? Categories2Cell
        }
        
        
        cell?.mainView.clipsToBounds = true
        cell?.layer.borderWidth = 1
        cell?.layer.borderColor = UIColor.lightGray.cgColor
        cell?.layer.masksToBounds = false
        
        let index = self.dealArray[indexPath.row]
        
        cell?.nameLbl.text = index.title
        cell?.priceLbl.text = String(index.price!)
        
        cell?.loadingView.startAnimating()
        if let imgUrl = index.images {
            let url = URL(string: ServerConstants.BASE_URL2 + imgUrl)
                cell?.itemImg.sd_setImage(with: url, completed: { (image, error, cachType, url) in
                    if error == nil {
                        cell?.itemImg.image = image!
                        cell?.loadingView.stopAnimating()
                    }
                })
        }
        
        return cell!
    }
    
    func getDeals() {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Please Wait".localized()
        hud.show(in: self.view)
        
        let defaults = UserDefaults.standard
        let id = defaults.value(forKey: "id") as? String ?? "0"
        
        let dealsUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.App_Ext + ServerConstants.DEALS_URL)
        
        let dealsParam: [String: String] = [
            "type": "1",
            "uid": id
        ]
        
        AF.request(dealsUrl!, method: .post, parameters: dealsParam).response { (response) in
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
                                            self.dealArray.append(model)
                                        }
                                        
                                        DispatchQueue.main.async {
                                            self.dealCollection.reloadData()
                                        }
                                    }
                                    
                                } else {
                                    if let message = msg["message"] as? String {
                                        DispatchQueue.main.async {
                                            self.refreshControl?.endRefreshing()
                                            self.noDataLbl.isHidden = false
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
