//
//  MyOrdersItemsVC.swift
//  Paradise
//
//  Created by Omar Warrayat on 09/03/2021.
//

import UIKit

class MyOrdersItemsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var itemsTable: UITableView!
    
    var itemsArray = [MyOrdersItemsModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.itemsTable.delegate = self
        self.itemsTable.dataSource = self
        self.itemsTable.backgroundColor = .white
        self.view.backgroundColor = .white
        self.itemsTable.register(UINib(nibName: "CategorySelectTableCell", bundle: nil), forCellReuseIdentifier: "CategorySelectTableCell")
        
        self.navigationText(title: "Items".localized())
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navColorBlack()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 123
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = self.itemsTable.dequeueReusableCell(withIdentifier: "CategorySelectTableCell") as? CategorySelectTableCell
        
        if cell == nil {
            let nib: [Any] = Bundle.main.loadNibNamed("CategorySelectTableCell", owner: self, options: nil)!
            cell = nib[0] as? CategorySelectTableCell
        }
        
        let index = itemsArray[indexPath.row]
        
//        cell?.favouriteImg.isHidden = true
//        cell?.addToCartView.isHidden = true
//        cell?.addCartFavoriteView.isHidden = true
        cell?.weightLbl.isHidden = true
        
        if index.quantity != nil {
            cell?.nameLbl.text = "Quantity: ".localized() + String(index.quantity!)
        }
        
        if index.total_unit_price != nil {
            cell?.priceLbl.text = "Total price: ".localized() + index.total_unit_price!
        }
        
        cell?.loadingView.startAnimating()
        
        if let imgUrl = index.image {
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
    
}
