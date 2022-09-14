//
//  Categories1Cell.swift
//  Paradise
//
//  Created by Omar Warrayat on 28/12/2020.
//

import UIKit
import NVActivityIndicatorView

class Categories1Cell: UICollectionViewCell {
    
    @IBOutlet weak var loadingView: NVActivityIndicatorView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var itemImg: UIImageView!
    @IBOutlet weak var itemView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
