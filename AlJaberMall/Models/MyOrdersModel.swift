//
//  MyOrdersModel.swift
//  Paradise
//
//  Created by Omar Warrayat on 09/03/2021.
//

import Foundation

class MyOrdersModel {
    var order_id: String?
    var state: String?
    var date: String?
    var total_order_price: String?
    var items = [MyOrdersItemsModel]()
    
    init() {
        //
    }
    
    init(data: [String: Any]) {
        if let order_id = data["order_id"] as? String {
            self.order_id = order_id
        }
        if let state = data["state"] as? String {
            self.state = state
        }
        if let date = data["date"] as? String {
            self.date = date
        }
        if let total_order_price = data["total_order_price"] as? String {
            self.total_order_price = total_order_price
        }
        if let items = data["items"] as? [[String: Any]] {
            for item in items {
                let model = MyOrdersItemsModel(data: item)
                self.items.append(model)
            }
        }
    }
}
