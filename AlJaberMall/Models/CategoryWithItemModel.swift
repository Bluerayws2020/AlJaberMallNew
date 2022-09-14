//
//  CategoryWithItemModel.swift
//  Paradise
//
//  Created by Omar Warrayat on 06/01/2021.
//

import Foundation

class CategoryWithItemModel {
    
    var id: String?
    var name: String?
    var image: String?
    var items = [ItemsModel]()


    init(data: [String: Any]) {
        if let id = data["id"] as? String {
            self.id = id
        }
        if let name = data["name"] as? String {
            self.name = name
        }
        if let image = data["image"] as? String {
            self.image = image
        }
        if let items = data["products"] as? [[String: Any]] {
            for item in items {
                let model = ItemsModel(data: item)
                self.items.append(model)
            }
        }
    }
}
