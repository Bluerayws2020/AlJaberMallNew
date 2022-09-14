//
//  OrdersCell.swift
//  Paradise
//
//  Created by Omar Warrayat on 09/03/2021.
//

import UIKit
import MOLH

class OrdersCell: UITableViewCell {
    
    @IBOutlet weak var arrowImg: UIImageView!
    @IBOutlet weak var paymentStatusLblMain: UILabel!
    @IBOutlet weak var totalPriceLblMain: UILabel!
    @IBOutlet weak var noOfItemsLblMain: UILabel!
    @IBOutlet weak var locationLblMain: UILabel!
    @IBOutlet weak var dateLblMain: UILabel!
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var orderNoLbl: UILabel!
    @IBOutlet weak var paymentStatusLbl: UILabel!
    @IBOutlet weak var totalPriceLbl: UILabel!
    @IBOutlet weak var noOfItemsLbl: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if MOLHLanguage.isRTLLanguage() {
            self.arrowImg.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        self.orderNoLbl.textAlignment = MOLHLanguage.isRTLLanguage() ? .right: .left
        self.paymentStatusLbl.textAlignment = MOLHLanguage.isRTLLanguage() ? .right: .left
        self.totalPriceLbl.textAlignment = MOLHLanguage.isRTLLanguage() ? .right: .left
        self.locationLbl.textAlignment = MOLHLanguage.isRTLLanguage() ? .right: .left
        self.dateLbl.textAlignment = MOLHLanguage.isRTLLanguage() ? .right: .left
        
        self.paymentStatusLblMain.textAlignment = MOLHLanguage.isRTLLanguage() ? .right: .left
        self.totalPriceLblMain.textAlignment = MOLHLanguage.isRTLLanguage() ? .right: .left
        self.noOfItemsLblMain.textAlignment = MOLHLanguage.isRTLLanguage() ? .right: .left
        self.locationLblMain.textAlignment = MOLHLanguage.isRTLLanguage() ? .right: .left
        self.dateLblMain.textAlignment = MOLHLanguage.isRTLLanguage() ? .right: .left
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //set the values for top,left,bottom,right margins
        let margins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        contentView.frame = contentView.frame.inset(by: margins)
    }
    
}
