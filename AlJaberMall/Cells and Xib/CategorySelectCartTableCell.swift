//
//  CategorySelectCartTableCell.swift
//  Zooney
//
//  Created by Omar Warrayat on 20/10/2021.
//

import UIKit
import MOLH
import NVActivityIndicatorView

class CategorySelectCartTableCell: UITableViewCell {

    @IBOutlet weak var loadingView: NVActivityIndicatorView!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var nameLbl : UILabel!
    @IBOutlet weak var priceLbl : UILabel!
    @IBOutlet weak var weightLbl : UILabel!
    @IBOutlet weak var favouriteImg: UIImageView!
    @IBOutlet weak var favouriteBtn: UIButton!
    @IBOutlet weak var addToCartBtn: UIButton!
    @IBOutlet weak var addToCartView: UIView!
    @IBOutlet weak var plusBtn: UIButton!
    @IBOutlet weak var minusBtn: UIButton!
    @IBOutlet weak var quantityLbl: UILabel!
    @IBOutlet weak var addCartFavoriteView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.addToCartView.layer.cornerRadius = 10
        self.addToCartView.layer.shadowColor = UIColor.black.cgColor
        self.addToCartView.layer.shadowOpacity = 0.5
        
        self.nameLbl.textAlignment = MOLHLanguage.isRTLLanguage() ? .right: .left
        self.priceLbl.textAlignment = MOLHLanguage.isRTLLanguage() ? .right: .left
        self.weightLbl.textAlignment = MOLHLanguage.isRTLLanguage() ? .right: .left
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
