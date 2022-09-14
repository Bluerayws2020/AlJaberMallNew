//
//  MyOrdersVC.swift
//  Paradise
//
//  Created by Omar Warrayat on 09/03/2021.
//

import UIKit
import Alamofire
import JGProgressHUD
import MOLH

class MyOrdersVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myOrdersTable: UITableView!
    @IBOutlet weak var noOrdersLbl: UILabel!
    
    var myOrdersArray = [MyOrdersModel]()
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.noOrdersLbl.isHidden = true
        
        self.myOrdersTable.separatorStyle = .none
        
        self.myOrdersTable.delegate = self
        self.myOrdersTable.dataSource = self
        self.myOrdersTable.register(UINib(nibName: "OrdersCell", bundle: nil), forCellReuseIdentifier: "OrdersCell")
        
        self.getMyOrders()
        
        self.myOrdersTable.alwaysBounceVertical = true
        self.myOrdersTable.bounces  = true
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        self.myOrdersTable.addSubview(refreshControl)
        
        self.navigationText(title: "My Orders".localized())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navColorBlack()
    }
    
    @objc func didPullToRefresh() {
        self.myOrdersArray.removeAll()
        self.myOrdersTable.reloadData()
        self.getMyOrders()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myOrdersArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 305
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyBoard.instantiateViewController(withIdentifier: "MyOrdersItemsVC") as! MyOrdersItemsVC
        vc.itemsArray = self.myOrdersArray[indexPath.row].items
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = self.myOrdersTable.dequeueReusableCell(withIdentifier: "OrdersCell") as? OrdersCell
        
        if cell == nil {
            let nib: [Any] = Bundle.main.loadNibNamed("OrdersCell", owner: self, options: nil)!
            cell = nib[0] as? OrdersCell
        }
        
        cell?.layer.borderWidth = 0
        cell?.layer.shadowColor = UIColor.black.cgColor
        cell?.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell?.layer.shadowRadius = 5
        cell?.layer.shadowOpacity = 0.1
        cell?.layer.masksToBounds = false
        
        cell?.mainView.layer.cornerRadius = 15
            cell?.mainView.clipsToBounds = true
            
            let index = myOrdersArray[indexPath.row]
            
            cell?.orderNoLbl.text = index.order_id
        
        cell?.dateLbl.text = index.date
        
        cell?.noOfItemsLbl.text = String(index.items.count)
        cell?.totalPriceLbl.text = index.total_order_price
        cell?.paymentStatusLbl.text = index.state
        
        //let text = index.area! + index.building_number! + "\n" + index.apartment_number! + "\n" + index.city! + "\n" + index.street!
        //cell?.locationLbl.text = text
        
        return cell!
    }
    
    func getMyOrders() {
            self.noOrdersLbl.isHidden = true
            let hud = JGProgressHUD(style: .light)
            hud.textLabel.text = "Please Wait".localized()
            hud.show(in: self.view)
            
            let defaults = UserDefaults.standard
            let id = defaults.value(forKey: "id") as! String
            
            let invoicesUrl = URL(string: ServerConstants.BASE_URL + ServerConstants.App_Ext + ServerConstants.GETINVOICES_URL)
            let invoicesParam: [String: String] = [
                "uid": id,
                "lang": MOLHLanguage.isRTLLanguage() ? "ar": "en"
            ]
            
            AF.request(invoicesUrl!, method: .post, parameters: invoicesParam).response { (response) in
                if response.error == nil {
                    do {
                        let jsonObj = try JSONSerialization.jsonObject(with: response.data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
                        
                        if jsonObj != nil {
                            if let msg = jsonObj!["msg"] as? [String: Any] {
                            if let status = msg["status"] as? Int {
                                if status == 1 {
                                    if let data = jsonObj!["data"] as? [[String: Any]] {
                                        for item in data {
                                            let model = MyOrdersModel(data: item)
                                            self.myOrdersArray.append(model)
                                        }
                                    }
                                    
                                    DispatchQueue.main.async {
                                        self.refreshControl?.endRefreshing()
                                        self.myOrdersTable.reloadData()
                                        hud.dismiss()
                                    }
                                    
                                } else {
                                    if let message = msg["message"] as? String {
                                        DispatchQueue.main.async {
                                            self.refreshControl?.endRefreshing()
                                            self.noOrdersLbl.isHidden = false
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
