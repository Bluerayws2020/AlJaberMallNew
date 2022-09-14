//
//  ItemDetailsVC.swift
//  Paradise
//
//  Created by Omar Warrayat on 03/02/2021.
//

import UIKit
import MOLH
import SDWebImage
import Alamofire
import JGProgressHUD

class ItemDetailsVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var itemImgView: UIView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var addCartBtn: UIButton!
    @IBOutlet weak var imagesCollection: UICollectionView!
    @IBOutlet weak var relatedCollection: UICollectionView!
    @IBOutlet weak var addCartViewTop: NSLayoutConstraint!
    @IBOutlet weak var itemImgViewHeight: NSLayoutConstraint!
    @IBOutlet weak var plusView: UIView!
    @IBOutlet weak var minusView: UIView!
    @IBOutlet weak var quantityLbl: UILabel!
    @IBOutlet weak var favouriteImg: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var noDataLbl: UILabel!
    
    @IBOutlet weak var leftArrowImg: UIImageView!
    @IBOutlet weak var rightArrowImg: UIImageView!
    @IBOutlet weak var leftArrowView: UIView!
    @IBOutlet weak var rightArrowView: UIView!
    
    var refreshControl: UIRefreshControl!
    
    var productModel = ProductDetailsModel()
    
    var pid: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationText(title: "Item details".localized())
        
        self.nameLbl.textAlignment = MOLHLanguage.isRTLLanguage() ? .right: .left
        self.descLbl.textAlignment = MOLHLanguage.isRTLLanguage() ? .right: .left
        self.priceLbl.textAlignment = MOLHLanguage.isRTLLanguage() ? .right: .left
        
        self.noDataLbl.isHidden = true
        self.relatedCollection.delegate = self
        self.relatedCollection.dataSource = self
        self.imagesCollection.delegate = self
        self.imagesCollection.dataSource = self
        
        let collLayout = UICollectionViewFlowLayout()
        collLayout.sectionInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        collLayout.scrollDirection = .horizontal
        collLayout.itemSize = CGSize(width: 80, height: 80)
        
        let collLayout2 = UICollectionViewFlowLayout()
        collLayout2.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collLayout2.minimumInteritemSpacing = 0
        collLayout2.minimumLineSpacing = 0
        collLayout2.scrollDirection = .horizontal
        collLayout2.itemSize = CGSize(width: UIScreen.main.bounds.width - 40, height: 320)
        
        self.plusView.layer.cornerRadius = 10
        self.minusView.layer.cornerRadius = 10
        
        self.relatedCollection.setCollectionViewLayout(collLayout, animated: false)
        self.relatedCollection.register(UINib(nibName: "AllCategoriesCell", bundle: Bundle.main), forCellWithReuseIdentifier: "AllCategoriesCell")
        
        self.imagesCollection.setCollectionViewLayout(collLayout2, animated: false)
        self.imagesCollection.register(UINib(nibName: "AllCategoriesCell", bundle: Bundle.main), forCellWithReuseIdentifier: "AllCategoriesCell")
        
        self.itemImgViewHeight.constant = self.view.frame.width - 40
        
        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.tintColor = .black
        
        if self.productModel.fav == 1 {
            self.favouriteImg.image = UIImage(named: "favouriteFill")
        }
        
        let defaults = UserDefaults.standard
        let id = "0"
        if id == nil || id == "" {
            self.getProductDetails(id: "\(0)")

        }else {
            self.getProductDetails(id: id)

        }
        
        self.imagesCollection.layer.borderWidth = 1
        self.imagesCollection.layer.borderColor = UIColor.lightGray.cgColor
        
        self.changeArrowsRadius()
        
        self.scrollView.alwaysBounceVertical = true
        self.scrollView.bounces  = true
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.scrollView.addSubview(refreshControl)
        
    }
    
    @IBAction func leftRightActions(sender: UIButton) {
        if sender.tag == 0 {
            let collectionBounds = self.imagesCollection.bounds
            let contentOffset = CGFloat(floor(self.imagesCollection.contentOffset.x - collectionBounds.size.width))
            self.moveImagesCollectionToFrame(contentOffset: contentOffset)
            
        } else if sender.tag == 1 {
            let collectionBounds = self.imagesCollection.bounds
            let contentOffset = CGFloat(floor(self.imagesCollection.contentOffset.x + collectionBounds.size.width))
            self.moveImagesCollectionToFrame(contentOffset: contentOffset)
            
        }
    }
    
    func moveImagesCollectionToFrame(contentOffset : CGFloat) {
        let frame: CGRect = CGRect(x : contentOffset ,y : self.imagesCollection.contentOffset.y ,width : self.imagesCollection.frame.width,height : self.imagesCollection.frame.height)
        self.imagesCollection.scrollRectToVisible(frame, animated: true)
    }
    
    func changeArrowsRadius() {
        self.rightArrowView.layer.cornerRadius = 12.5
        self.leftArrowView.layer.cornerRadius = 12.5
        
        self.rightArrowView.backgroundColor = .white
        self.leftArrowView.backgroundColor = .white
        
        self.rightArrowView.layer.shadowColor = UIColor.black.cgColor
        self.rightArrowView.layer.shadowOpacity = 0.3
        
        self.leftArrowView.layer.shadowColor = UIColor.black.cgColor
        self.leftArrowView.layer.shadowOpacity = 0.3
        
        if MOLHLanguage.isRTLLanguage() == true {
            self.leftArrowImg.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.rightArrowImg.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navColorBlack()
    }
    
    @objc func didPullToRefresh() {
        //self.relatedArray.removeAll()
        //self.relatedCollection.reloadData()
        //self.getRelated()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.relatedCollection {
            return self.productModel.related.count
            
        } else {
            return self.productModel.images.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.relatedCollection {
            var cell = self.relatedCollection.dequeueReusableCell(withReuseIdentifier: "AllCategoriesCell", for: indexPath) as? AllCategoriesCell
            
            if cell == nil {
                let nib: [Any] = Bundle.main.loadNibNamed("AllCategoriesCell", owner: self, options: nil)!
                cell = nib[0] as? AllCategoriesCell
            }
            
            cell?.mainView.layer.cornerRadius = 10
            cell?.mainView.clipsToBounds = true
            cell?.mainView.layer.borderWidth = 1
            cell?.mainView.layer.borderColor = UIColor.lightGray.cgColor
            cell?.layer.borderWidth = 0
            cell?.layer.shadowColor = UIColor.black.cgColor
            cell?.layer.shadowOffset = CGSize(width: 0, height: 0)
            cell?.layer.shadowRadius = 5
            cell?.layer.shadowOpacity = 0.2
            cell?.layer.masksToBounds = false
            
            cell?.img.contentMode = .scaleAspectFit
            
            cell?.titleLbl.isHidden = true
            
            cell?.loadingView.startAnimating()
            if let imgUrl = self.productModel.related[indexPath.row].images {
                let url = URL(string: ServerConstants.BASE_URL2 + imgUrl)
                cell?.img.sd_setImage(with: url, completed: { (image, error, cachType, url) in
                    if error == nil {
                        cell?.img.image = image!
                        cell?.loadingView.stopAnimating()
                    }
                })
               }
            
            return cell!
            
        } else {
            
            var cell = self.imagesCollection.dequeueReusableCell(withReuseIdentifier: "AllCategoriesCell", for: indexPath) as? AllCategoriesCell
            
            if cell == nil {
                let nib: [Any] = Bundle.main.loadNibNamed("AllCategoriesCell", owner: self, options: nil)!
                cell = nib[0] as? AllCategoriesCell
            }
            
//            cell?.mainView.layer.cornerRadius = 10
//            cell?.mainView.clipsToBounds = true
//            cell?.mainView.layer.borderWidth = 1
//            cell?.mainView.layer.borderColor = UIColor.lightGray.cgColor
//            cell?.layer.borderWidth = 0
//            cell?.layer.shadowColor = UIColor.black.cgColor
//            cell?.layer.shadowOffset = CGSize(width: 0, height: 0)
//            cell?.layer.shadowRadius = 5
//            cell?.layer.shadowOpacity = 0.2
//            cell?.layer.masksToBounds = false
            
            cell?.titleLbl.isHidden = true
            
            cell?.img.contentMode = .scaleAspectFit
            
            if let imgUrl = self.productModel.images[indexPath.row] {
            let url = URL(string: ServerConstants.BASE_URL2 + imgUrl)
                cell?.img.sd_setImage(with: url, completed: { (image, error, cachType, url) in
                    if error == nil {
                        cell?.img.image = image!
                    }
                })
               }
    
            return cell!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.relatedCollection {
            let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
            let vc = storyBoard.instantiateViewController(withIdentifier: "ItemDetailsVC") as! ItemDetailsVC
            vc.pid = self.productModel.related[indexPath.row].pid
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func setData() {
        self.imagesCollection.reloadData()
        self.relatedCollection.reloadData()
        
        if self.view.frame.height > 800 {
            self.addCartViewTop.constant = 20
        }
            
        if self.productModel.fav == 1 {
            self.favouriteImg.image = UIImage(named: "favouriteFill")
        }
                
        self.addCartBtn.layer.cornerRadius = 10
                
        self.nameLbl.text = self.productModel.title
        self.descLbl.text = self.productModel.body
        
        if self.productModel.price != nil {
            self.priceLbl.text = String(self.productModel.price!)
        }
        
    }
    
    func getProductDetails(id:String) {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Please Wait".localized()
        hud.show(in: self.view)

     
        
        
        
        
        let productUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.App_Ext + ServerConstants.GetProductDetails_Url)
        let productParam: [String: String] = [
            "pid": self.pid!,
            "uid": String(id)
        ]

        AF.request(productUrl!, method: .post, parameters: productParam).response { (response) in
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
                                        let model = ProductDetailsModel(data: data)
                                        self.productModel = model
                                        
                                        DispatchQueue.main.async {
                                            self.setData()
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
    
    @IBAction func plusMinusAction(sender: UIButton) {
        //0 for add
        // else for minus
        if sender.tag == 0 {
            self.quantityLbl.text = String(Int(self.quantityLbl.text!)! + 1)
            self.minusView.backgroundColor = UIColor(red: 149/255, green: 15/255, blue: 30/255, alpha: 1)
            
        } else {
            if self.quantityLbl.text != "0" {
                self.quantityLbl.text = String(Int(self.quantityLbl.text!)! - 1)
                
                if self.quantityLbl.text == "0" {
                    self.minusView.backgroundColor = UIColor(red: 139/255, green: 143/255, blue: 143/255, alpha: 1)
                }
                
            }
        }
    }
    
    @IBAction func addToCart(sender: UIButton) {
        if quantityLbl.text != "0" {
            let hud = JGProgressHUD(style: .light)
            hud.textLabel.text = "Please Wait".localized()
            hud.show(in: self.view)

            let defaults = UserDefaults.standard
            let id = defaults.value(forKey: "id") as! String

            let addToCartUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.App_Ext + ServerConstants.ADDTOCART_URL)
            let addToCartParam: [String: String] = [
                "vid": self.productModel.vid!,
                "uid": id,
                "quantity": self.quantityLbl.text!,
                "price": String(self.productModel.price!)

            ]

            AF.request(addToCartUrl!, method: .post, parameters: addToCartParam).response { (response) in
                if response.error == nil {
                    do {
                        let jsonObj = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]

                        if jsonObj != nil {
                            if let msg = jsonObj!["msg"] as? [String: Any] {
                                if let status = msg["status"] as? Int {
                                    if status == 1 {
                                        if let message = msg["message"] as? String {
                                            DispatchQueue.main.async {
                                                self.showSuccessHudAndOut(msg: message, hud: hud)
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
    }

    @IBAction func favouriteAction(sender: UIButton) {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Please Wait".localized()
        hud.show(in: self.view)

        let defaults = UserDefaults.standard
        let id = defaults.value(forKey: "id") as! String

        let addFavouriteUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.App_Ext + ServerConstants.ADDFAVOURITE_URL)
        let addFavouriteParam: [String: String] = [
            "uid": id,
            "product_id": self.productModel.pid!

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
                                            
                                            if self.productModel.fav == 0 {
                                                self.productModel.fav = 1
                                                self.favouriteImg.image = UIImage(named: "favouriteFill")
                                                
                                            } else {
                                                self.productModel.fav = 0
                                                self.favouriteImg.image = UIImage(named: "favouriteEmpty")
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

}
