//
//  User.swift
//  Breeze
//
//  Created by HAIYING WENG on 8/3/19.
//  Copyright © 2019 Haiying Weng. All rights reserved.
//

import Foundation

class User {
    var uid: String?
    var username: String?
    var profilePic: String?
    var email: String?
    var bio: String? 
    
    init(dictionary:[String:Any]) {
        self.username = dictionary["username"] as? String
        self.profilePic = dictionary["profilePic"] as? String
        self.email = dictionary["email"] as? String
        self.bio = dictionary["bio"] as? String
    }
    
}
