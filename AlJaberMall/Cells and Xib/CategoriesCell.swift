//
//  CategoriesCell.swift
//  Paradise
//
//  Created by Omar Warrayat on 28/12/2020.
//

import UIKit
import SDWebImage
import MOLH

protocol CategoryDelegate {
    func cellSelected(pid: String, actionType: Int, cellIndex: Int?, collection: UICollectionView?)
    
}

extension CategoryDelegate {
    func cellSelected(pid: String, actionType: Int, cellIndex: Int?, collection: UICollectionView?) {}
}

class CategoriesCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var cellCollection: UICollectionView!
    
    var CategoryDelegate: CategoryDelegate?
    
    var itemArray = [ItemsModel]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.cellCollection.delegate = self
        self.cellCollection.dataSource = self
        
        if MOLHLanguage.isRTLLanguage() == true {
            self.cellCollection.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.cellCollection.semanticContentAttribute = .forceLeftToRight
        }
        
        let collLayout = UICollectionViewFlowLayout()
        //let width = (UIScreen.main.bounds.width - 50) / 3
        //self.categoryCollectionHeight.constant = width * 2 + 50
        collLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        collLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        collLayout.itemSize = CGSize(width: 155, height: 210)
        
        cellCollection.backgroundColor = .clear
        cellCollection.setCollectionViewLayout(collLayout, animated: false)
        
        self.cellCollection.register(UINib(nibName: "Categories2Cell", bundle: Bundle.main), forCellWithReuseIdentifier: "Categories2Cell")
        
    }
    
    func reloadData(itemArray: [ItemsModel]) {
        self.itemArray = itemArray
        self.cellCollection.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //set the values for top,left,bottom,right margins
        let margins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        contentView.frame = contentView.frame.inset(by: margins)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.CategoryDelegate?.cellSelected(pid: self.itemArray[indexPath.row].pid!, actionType: 1, cellIndex: nil, collection: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = self.cellCollection.dequeueReusableCell(withReuseIdentifier: "Categories2Cell", for: indexPath) as? Categories2Cell
        
        if cell == nil {
            let nib: [Any] = Bundle.main.loadNibNamed("Categories2Cell", owner: self, options: nil)!
            cell = nib[0] as? Categories2Cell
        }
        
        cell?.mainView.layer.cornerRadius = 10
        cell?.mainView.clipsToBounds = true
        cell?.layer.borderWidth = 0
        cell?.layer.shadowColor = UIColor.black.cgColor
        cell?.layer.shadowOffset = CGSize(width: 0, height: 0)
        cell?.layer.shadowRadius = 5
        cell?.layer.shadowOpacity = 0.2
        cell?.layer.masksToBounds = false
        
        let index = self.itemArray[indexPath.row]
        
        if MOLHLanguage.isRTLLanguage() == true {
            cell?.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
        cell?.nameLbl.text = index.title
        
        if index.price != nil {
            cell?.priceLbl.text = String(index.price!)
        }
        
        cell?.loadingView.startAnimating()
        if let imgUrl = index.images {
            let url = URL(string: ServerConstants.BASE_URL2 + imgUrl)
                cell?.itemImg.sd_setImage(with: url, completed: { (image, error, cachType, url) in
                    if error == nil {
                        cell?.itemImg.image = image!
                        cell?.loadingView.stopAnimating()
                    }
                })
        }
        
        return cell!
    }
    
    @objc func addToCartAction(sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let cell = cellCollection!.cellForItem(at: indexPath) as! Categories2Cell
        cell.addToCartView.isHidden = false
    }
    
}
