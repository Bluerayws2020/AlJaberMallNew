//
//  PayWithCartCell.swift
//  Paradise
//
//  Created by Omar Warrayat on 24/02/2021.
//

import UIKit

class PayWithCartCell: UITableViewCell {
    
    @IBOutlet weak var paymentTypeView: UIView!
    @IBOutlet weak var recieptTypeView: UIView!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var paymentMethodTxt: UITextField!
    @IBOutlet weak var recieptMethodTxt: UITextField!
    @IBOutlet weak var paymentMethodLbl: UILabel!
    @IBOutlet weak var recieptMethodLbl: UILabel!
    @IBOutlet weak var promoTxt: UITextField!
    @IBOutlet weak var applyBtn: UIButton!
    @IBOutlet weak var discountLbl: UILabel!
    @IBOutlet weak var deliveryLbl: UILabel!
    @IBOutlet weak var subTotalLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.paymentTypeView.layer.cornerRadius = 10
        self.paymentTypeView.layer.shadowOpacity = 0.3
        self.paymentTypeView.layer.shadowColor = UIColor.black.cgColor
        
        self.recieptTypeView.layer.cornerRadius = 10
        self.recieptTypeView.layer.shadowOpacity = 0.3
        self.recieptTypeView.layer.shadowColor = UIColor.black.cgColor
        
        self.applyBtn.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
