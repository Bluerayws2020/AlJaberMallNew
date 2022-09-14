//
//  ItemsModel.swift
//  Paradise
//
//  Created by Omar Warrayat on 18/01/2021.
//

import Foundation

class ItemsModel {
    
    var pid: String?
    var vid: String?
    var title: String?
    var price: Double?
    var fav: Int?
    var images: String?
    
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
        if let images = data["images"] as? String {
            self.images = images
        }
    }
    
}
