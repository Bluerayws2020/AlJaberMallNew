//
//  BranchModel.swift
//  Paradise
//
//  Created by Omar Warrayat on 12/04/2021.
//

import Foundation

class BranchModel {
    
    var id: Int?
    var name_ar: String?
    var name_en: String?
    
    init(data: [String: Any]) {
        if let id = data["id"] as? Int {
            self.id = id
        }
        if let name_ar = data["name_ar"] as? String {
            self.name_ar = name_ar
        }
        if let name_en = data["name_en"] as? String {
            self.name_en = name_en
        }
    }
}
