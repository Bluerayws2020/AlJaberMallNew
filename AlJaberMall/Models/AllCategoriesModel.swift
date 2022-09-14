//
//  AllCategoriesModel.swift
//  Paradise
//
//  Created by Omar Warrayat on 21/01/2021.
//

import Foundation

class AllCategoriesModel {
    
    var id: Int?
    var created_by: String?
    var category_name_ar: String?
    var category_name_en: String?
    var category_image: String?
    var status: String?

    init(data: [String: Any]) {
        if let id = data["id"] as? Int {
            self.id = id
        }
        if let created_by = data["created_by"] as? String {
            self.created_by = created_by
        }
        if let category_name_ar = data["category_name_ar"] as? String {
            self.category_name_ar = category_name_ar
        }
        if let category_name_en = data["category_name_en"] as? String {
            self.category_name_en = category_name_en
        }
        if let category_image = data["category_image"] as? String {
            self.category_image = category_image
        }
        if let status = data["status"] as? String {
            self.status = status
        }
    }
    
}
