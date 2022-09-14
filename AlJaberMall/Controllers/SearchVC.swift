//
//  SearchVC.swift
//  Paradise
//
//  Created by Omar Warrayat on 16/08/2021.
//

import UIKit
import MOLH
import Alamofire
import JGProgressHUD

class SearchVC: UIViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var itemsCollection: UICollectionView!
    @IBOutlet weak var noDataLbl: UILabel!
    
    var itemArray = [ItemsModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noDataLbl.isHidden = false
        
        navigationItem.backBarButtonItem = UIBarButtonItem(
        title: "", style: .plain, target: nil, action: nil)
        
        self.navigationText(title: "Search".localized())
        
        self.search.delegate = self
        self.search.semanticContentAttribute = MOLHLanguage.isRTLLanguage() ? .forceRightToLeft: .forceLeftToRight
        self.search.backgroundColor = UIColor(red: 242/255, green: 246/255, blue: 247/255, alpha: 1)
        
        self.itemsCollection.backgroundColor = .clear
        self.itemsCollection.delegate = self
        self.itemsCollection.dataSource = self
        
        self.search.placeholder = "Search For Items".localized()
        (self.search.value(forKey: "cancelButton") as! UIButton).setTitle("Cancel".localized(), for: .normal)
        (self.search.value(forKey: "cancelButton") as! UIButton).setTitleColor(.darkGray, for: .normal)
        
        self.search.tintColor = .darkGray
        
        if let textFieldInsideSearchBar = self.search.value(forKey: "searchField") as? UITextField,
           let glassIconView = textFieldInsideSearchBar.leftView as? UIImageView {
            glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
            glassIconView.tintColor = .darkGray
        }
        
        let textFieldOfSearchBar = self.search.value(forKey: "searchField") as? UITextField
        textFieldOfSearchBar?.textAlignment = MOLHLanguage.isRTLLanguage() ? .right: .left
        
        if #available(iOS 13.0, *) {
                self.search.searchTextField.textColor = .black
            
            } else {
                // Fallback on earlier versions
                if let searchField = self.search.value(forKey: "searchField") as? UITextField {
                    searchField.textColor = .black
                    searchField.tintColor = .red
                }
            }
        
        let collLayout = UICollectionViewFlowLayout()
        let width = (UIScreen.main.bounds.width - 40) / 2
        collLayout.sectionInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        collLayout.scrollDirection = UICollectionView.ScrollDirection.vertical
        collLayout.itemSize = CGSize(width: width, height: 200)
        itemsCollection.setCollectionViewLayout(collLayout, animated: false)
        
        self.itemsCollection.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.itemsCollection.addGestureRecognizer(tap)
        
        self.itemsCollection.register(UINib(nibName: "Categories2Cell", bundle: Bundle.main), forCellWithReuseIdentifier: "Categories2Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navColorBlack()
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.search.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let searchText = searchBar.text
        
        if searchText != "" {
            self.itemArray.removeAll()
            self.itemsCollection.reloadData()
            self.searchAction(searchTxt: searchText!)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
//        let vc = storyBoard.instantiateViewController(withIdentifier: "ItemDetailsVC") as! ItemDetailsVC
//        vc.itemDetail = self.itemArray[indexPath.row]
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = self.itemsCollection.dequeueReusableCell(withReuseIdentifier: "Categories2Cell", for: indexPath) as? Categories2Cell
        
        if cell == nil {
            let nib: [Any] = Bundle.main.loadNibNamed("Categories2Cell", owner: self, options: nil)!
            cell = nib[0] as? Categories2Cell
        }
        
        cell?.mainView.layer.cornerRadius = 10
        cell?.mainView.clipsToBounds = true
        cell?.layer.borderWidth = 0
        cell?.layer.shadowColor = UIColor.black.cgColor
        cell?.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell?.layer.shadowRadius = 5
        cell?.layer.shadowOpacity = 0.2
        cell?.layer.masksToBounds = false
        
        let index = self.itemArray[indexPath.row]
        
        cell?.nameLbl.text = index.title
        
        if index.price != nil {
            cell?.priceLbl.text = String(index.price!)
        }
        
        cell?.loadingView.startAnimating()
        
        if let imgUrl = self.itemArray[indexPath.row].images {
        let url = URL(string: imgUrl)
            cell?.itemImg.sd_setImage(with: url, completed: { (image, error, cachType, url) in
                if error == nil {
                    cell?.itemImg.image = image!
                    cell?.loadingView.stopAnimating()
                }
            })
           }
        
        return cell!
    }
    
    func searchAction(searchTxt: String) {
        let hud = JGProgressHUD(style: .light)
        hud.textLabel.text = "Please Wait".localized()
        hud.show(in: self.view)
        
        let defaults = UserDefaults.standard
        let id = defaults.value(forKey: "id") as! String
        
        let searchUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.App_Ext + ServerConstants.Search_URL)
        
        let searchParam: [String: String] = [
            "uid": id,
            "lang": MOLHLanguage.isRTLLanguage() ? "ar": "en",
            "key": searchTxt
        ]
        
        AF.request(searchUrl!, method: .post, parameters: searchParam).response { (response) in
            if response.error == nil {
                do {
                    let jsonObj = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                    
                    if jsonObj != nil {
                        if let msg = jsonObj!["msg"] as? [String: Any] {
                            if let status = msg["status"] as? Int {
                                if status == 1 {
                                    if let data = jsonObj!["data"] as? [[String: Any]] {
                                        for item in data {
                                            let model = ItemsModel(data: item)
                                            self.itemArray.append(model)
                                        }
                                        
                                        DispatchQueue.main.async {
                                            hud.dismiss()
                                            
                                            if self.itemArray.count == 0 {
                                                self.noDataLbl.isHidden = false
                                            } else {
                                                self.noDataLbl.isHidden = true
                                            }
                                            
                                            self.itemsCollection.reloadData()
                                        }
                                    }
                                    
                                } else {
                                    if let message = msg["message"] as? String {
                                        DispatchQueue.main.async {
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
                }
            } else {
                print("Error")
                self.internetError(hud: hud)
            }
        }
        
    }
    
}
