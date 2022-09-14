//
//  CategoryTableViewCell.swift
//  AlJaberMall
//
//  Created by Omar Warrayat on 20/09/2022.
//

import UIKit
import NVActivityIndicatorView
class CategoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var loadingView: NVActivityIndicatorView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


}
