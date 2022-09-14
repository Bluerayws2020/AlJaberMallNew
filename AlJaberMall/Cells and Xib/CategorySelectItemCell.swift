//
//  CategorySelectItemCell.swift
//  Paradise
//
//  Created by Omar Warrayat on 31/01/2021.
//

import UIKit
import MOLH

class CategorySelectItemCell: UICollectionViewCell {

    @IBOutlet weak var categoryNameLbl: UILabel!
    @IBOutlet weak var selectView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
//    override var isSelected: Bool {
//            didSet {
//                self.selectView.backgroundColor = isSelected ? UIColor(red: 184/255, green: 22/255, blue: 43/255, alpha: 1) : UIColor.clear
//            }
//          }
    
    func toggleSelected ()
        {
        if (isSelected) {
            self.selectView.backgroundColor = UIColor(red: 184/255, green: 22/255, blue: 43/255, alpha: 1)
            
            } else {
                self.selectView.backgroundColor = UIColor.clear
            }
        }

}
