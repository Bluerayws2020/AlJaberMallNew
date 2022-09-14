//
//  ProductDetails.swift
//  Zooney
//
//  Created by Omar Warrayat on 17/10/2021.
//

import Foundation

class ProductDetailsModel {
    var pid: String?
    var vid: String?
    var title: String?
    var fav: Int?
    var main_department: String?
    var sub_department: String?
    var orginal_country: String?
    var brand: String?
    var body: String?
    var price: Double?
    var related = [ItemsModel]()
    var images = [String?]()
    
    init() {
        //
    }
    
    init(data: [String: Any]) {
        if let pid = data["pid"] as? String {
            self.pid = pid
        }
        if let vid = data["vid"] as? String {
            self.vid = vid
        }
        if let title = data["title"] as? String {
            self.title = title
        }
        if let price = data["price"] as? Double {
            self.price = price
        }
        if let fav = data["fav"] as? Int {
            self.fav = fav
        }
        if let main_department = data["main_department"] as? String {
            self.main_department = main_department
        }
        if let sub_department = data["sub_department"] as? String {
            self.sub_department = sub_department
        }
        if let orginal_country = data["orginal_country"] as? String {
            self.orginal_country = orginal_country
        }
        if let brand = data["brand"] as? String {
            self.brand = brand
        }
        if let body = data["body"] as? String {
            self.body = body
        }
        if let related = data["related"] as? [[String: Any]] {
            for item in related {
                let model = ItemsModel(data: item)
                self.related.append(model)
            }
        }
        if let images = data["images"] as? [[String: Any]] {
            for item in images {
                if let url = item["url"] as? String {
                    self.images.append(url)
                }
            }
        }
    }
    
}
