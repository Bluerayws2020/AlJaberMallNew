//
//  Categories2Cell.swift
//  Paradise
//
//  Created by Omar Warrayat on 28/12/2020.
//

import UIKit
import MOLH
import NVActivityIndicatorView

class Categories2Cell: UICollectionViewCell {
    
    @IBOutlet weak var loadingView: NVActivityIndicatorView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var favouriteImg: UIImageView!
    @IBOutlet weak var favouriteBtn: UIButton!
    @IBOutlet weak var itemImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var addToCartBtn: UIButton!
    @IBOutlet weak var addToCartView: UIView!
    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var minusBtn: UIButton!
    @IBOutlet weak var quantityLbl: UILabel!
    
   
    
    @IBOutlet weak var add_to_cart: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.addToCartView.layer.cornerRadius = 10
//        self.addToCartView.layer.shadowColor = UIColor.black.cgColor
//        self.addToCartView.layer.shadowOpacity = 0.5
        
    }

}
