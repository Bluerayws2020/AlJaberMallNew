//
//  LocationsModel.swift
//  Paradise
//
//  Created by Omar Warrayat on 28/02/2021.
//

import Foundation

class LocationsModel {
    
    var profile_id: String?
    var is_default: String?
    var city: String?
    var area: String?
    var streetnum: String?
    var buildNum: String?
    var depnum: String?
    var lang: String?
    var latitude: String?
    
    init() {
        //
    }
    
    init(data: [String: Any]) {
        if let profile_id = data["profile_id"] as? String {
            self.profile_id = profile_id
        }
        if let is_default = data["is_default"] as? String {
            self.is_default = is_default
        }
        if let city = data["city"] as? String {
            self.city = city
        }
        if let area = data["area"] as? String {
            self.area = area
        }
        if let streetnum = data["streetnum"] as? String {
            self.streetnum = streetnum
        }
        if let buildNum = data["buildNum"] as? String {
            self.buildNum = buildNum
        }
        if let depnum = data["depnum"] as? String {
            self.depnum = depnum
        }
        if let lang = data["lang"] as? String {
            self.lang = lang
        }
        if let latitude = data["latitude"] as? String {
            self.latitude = latitude
        }
    }
    
}
