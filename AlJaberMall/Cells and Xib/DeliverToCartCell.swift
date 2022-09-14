//
//  DeliverToCartCell.swift
//  Paradise
//
//  Created by Omar Warrayat on 24/02/2021.
//

import UIKit

class DeliverToCartCell: UITableViewCell {
    
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var locationBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.locationView.layer.cornerRadius = 10
        self.locationView.layer.shadowOpacity = 0.3
        self.locationView.layer.shadowColor = UIColor.black.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
