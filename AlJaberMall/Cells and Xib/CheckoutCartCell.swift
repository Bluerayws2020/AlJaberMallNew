//
//  CheckoutCartCell.swift
//  Paradise
//
//  Created by Omar Warrayat on 24/02/2021.
//

import UIKit

class CheckoutCartCell: UITableViewCell {
    
    @IBOutlet weak var checkoutBtn: UIButton!
    @IBOutlet weak var checkoutView: UIView!
    @IBOutlet weak var checkoutBtnWidth: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.checkoutView.layer.cornerRadius = 25
        self.checkoutView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
