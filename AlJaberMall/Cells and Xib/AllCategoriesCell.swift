//
//  AllCategoriesCell.swift
//  Paradise
//
//  Created by Omar Warrayat on 21/01/2021.
//

import UIKit
import NVActivityIndicatorView

class AllCategoriesCell: UICollectionViewCell {
    
    @IBOutlet weak var loadingView: NVActivityIndicatorView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
