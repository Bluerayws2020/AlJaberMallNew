//
//  LoginModel.swift
//  Paradise
//
//  Created by Omar Warrayat on 03/01/2021.
//

import Foundation

class LoginModel {
    var access_token: String?
    var status: Bool?
    var user: [String: Any]?
    var id: Int?
    var name: String?
    var user_type: String?
    var token_type: String?
    var expires_in: Int?
    var error: String?
    var msg: String?
    var provider_status: String?
    
    init(data: [String: Any]) {
        if let access_token = data["access_token"] as? String {
            self.access_token = access_token
        }
        if let status = data["status"] as? Bool {
            self.status = status
        }
        if let user = data["user"] as? [String: Any] {
            if let id = user["id"] as? Int {
                self.id = id
            }
            if let name = user["name"] as? String {
                self.name = name
            }
            if let user_type = user["user_type"] as? String {
                self.user_type = user_type
            }
            if let provider_status = user["provider_status"] as? String {
                self.provider_status = provider_status
            }
        }
        if let token_type = data["token_type"] as? String {
            self.token_type = token_type
        }
        if let expires_in = data["expires_in"] as? Int {
            self.expires_in = expires_in
        }
        if let error = data["error"] as? String {
            self.error = error
        }
        if let msg = data["msg"] as? String {
            self.msg = msg
        }
    }
    
}
