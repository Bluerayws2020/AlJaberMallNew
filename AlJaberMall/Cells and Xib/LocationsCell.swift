//
//  LocationsCell.swift
//  Paradise
//
//  Created by Omar Warrayat on 25/02/2021.
//

import UIKit

class LocationsCell: UITableViewCell {
    
    @IBOutlet weak var radioImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var radionBtn: UIButton!
    @IBOutlet weak var deleteImg: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //set the values for top,left,bottom,right margins
        let margins = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        contentView.frame = contentView.frame.inset(by: margins)
    }
    
}
