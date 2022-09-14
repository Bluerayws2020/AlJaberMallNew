//
//  Categories11Cell.swift
//  Paradise
//
//  Created by Omar Warrayat on 21/01/2021.
//

import UIKit
import MOLH

protocol CategorySelectedDelegate {
    func CategoryCellSelected(CategoryIndex: Int, selectType: String)
}

extension CategorySelectedDelegate {
    func CategoryCellSelected(CategoryIndex: Int, selectType: String) {}
}

class Categories11Cell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var cellCollection: UICollectionView!
    @IBOutlet weak var searchBtn: UIButton!
    
    var categoriesArray = [CategoryWithItemModel]()
    
    var CategorySelectedDelegate: CategorySelectedDelegate?
    
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
        collLayout.itemSize = CGSize(width: 79, height: 105)
        
        cellCollection.backgroundColor = .clear
        
        cellCollection.setCollectionViewLayout(collLayout, animated: false)
        
        self.cellCollection.register(UINib(nibName: "Categories1Cell", bundle: Bundle.main), forCellWithReuseIdentifier: "Categories1Cell")
        
    }
    
    func reloadData(categoriesArray: [CategoryWithItemModel]) {
        self.categoriesArray = categoriesArray
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
    
    @IBAction func searchAction(sender: UIButton) {
        self.CategorySelectedDelegate?.CategoryCellSelected(CategoryIndex: 0, selectType: "search")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.categoriesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.CategorySelectedDelegate?.CategoryCellSelected(CategoryIndex: indexPath.row, selectType: "Item")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = self.cellCollection.dequeueReusableCell(withReuseIdentifier: "Categories1Cell", for: indexPath) as? Categories1Cell
        
        if cell == nil {
            let nib: [Any] = Bundle.main.loadNibNamed("Categories1Cell", owner: self, options: nil)!
            cell = nib[0] as? Categories1Cell
        }
        
        if MOLHLanguage.isRTLLanguage() == true {
            cell?.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
        cell?.loadingView.startAnimating()
        if let imgUrl = self.categoriesArray[indexPath.row].image {
        let url = URL(string: imgUrl)
            cell?.itemImg.sd_setImage(with: url, completed: { (image, error, cachType, url) in
                if error == nil {
                    cell?.itemImg.image = image!
                    cell?.loadingView.stopAnimating()
                }
            })
           }
        
        cell?.nameLbl.text = self.categoriesArray[indexPath.row].name
        
        cell?.itemView.layer.cornerRadius = 25
        cell?.itemView.clipsToBounds = true
        
        return cell!
    }
    
}
