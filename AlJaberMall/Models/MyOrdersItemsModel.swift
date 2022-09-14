//
//  MyOrdersItemsModel.swift
//  Paradise
//
//  Created by Omar Warrayat on 09/03/2021.
//

import Foundation

class MyOrdersItemsModel {
    var order_item_id: String?
    var title: String?
    var quantity: Int?
    var unit_price: String?
    var total_unit_price: String?
    var image: String?
    
    init() {
        //
    }
    
    init(data: [String: Any]) {
        if let order_item_id = data["order_item_id"] as? String {
            self.order_item_id = order_item_id
        }
        if let title = data["title"] as? String {
            self.title = title
        }
        if let quantity = data["quantity"] as? Int {
            self.quantity = quantity
        }
        if let unit_price = data["unit_price"] as? String {
            self.unit_price = unit_price
        }
        if let total_unit_price = data["total_unit_price"] as? String {
            self.total_unit_price = total_unit_price
        }
        if let image = data["image"] as? String {
            self.image = image
        }
    }
}
