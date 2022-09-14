//
//  CartModel.swift
//  Paradise
//
//  Created by Omar Warrayat on 24/02/2021.
//

import Foundation

class CartModel {
    
    var item_id: Int?
    var item_name_ar: String?
    var item_name_en: String?
    var item_on_sale_price: String?
    var item_price: String?
    var category_name_ar: String?
    var category_name_en: String?
    var item_image: String?
    var sale_price: String?
    var sale_quantity: String?
    var total_price: Double?
    
    init() {
        //
    }
    
    init(data: [String: Any]) {
        if let item_id = data["item_id"] as? Int {
            self.item_id = item_id
        }
        if let item_name_ar = data["item_name_ar"] as? String {
            self.item_name_ar = item_name_ar
        }
        if let item_name_en = data["item_name_en"] as? String {
            self.item_name_en = item_name_en
        }
        if let item_on_sale_price = data["item_on_sale_price"] as? String {
            self.item_on_sale_price = item_on_sale_price
        }
        if let item_price = data["item_price"] as? String {
            self.item_price = item_price
        }
        if let category_name_ar = data["category_name_ar"] as? String {
            self.category_name_ar = category_name_ar
        }
        if let category_name_en = data["category_name_en"] as? String {
            self.category_name_en = category_name_en
        }
        if let item_image = data["item_image"] as? String {
            self.item_image = item_image
        }
        if let sale_price = data["sale_price"] as? String {
            self.sale_price = sale_price
        }
        if let sale_quantity = data["sale_quantity"] as? String {
            self.sale_quantity = sale_quantity
        }
        if let total_price = data["total_price"] as? Double {
            self.total_price = total_price
        }
    }
    
}
