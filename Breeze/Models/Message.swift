//
//  Message.swift
//  Breeze
//
//  Created by HAIYING WENG on 8/4/19.
//  Copyright © 2019 Haiying Weng. All rights reserved.
//

import Foundation
import Firebase

class Message {
    
    var message: String?
    var senderID: String?
    var recipientID: String?
    var time: String?
    var imageUrl: String?
    var imageWidth: Float?
    var imageHeight: Float?
    
    init(dictionary:[String:Any]) {
        self.message = dictionary["message"] as? String
        self.senderID = dictionary["senderID"] as? String
        self.recipientID = dictionary["recipientID"] as? String
        self.time = dictionary["time"] as? String
        self.imageUrl = dictionary["imageUrl"] as? String
        self.imageWidth = dictionary["imageWidth"] as? Float
        self.imageHeight = dictionary["imageHeight"] as? Float
    }
    
    func getFriendID() -> String? {
        if senderID == Auth.auth().currentUser?.uid {
        return recipientID
        } else {
        return senderID
        }
    }
    
    func getTime() -> String {
        let dateFormatter = DateFormatter()
//        let now = Date()
        let timeInSeconds = Double(self.time!)
        let messageDate = Date(timeIntervalSince1970: timeInSeconds!)
        var time: String!
        if Calendar.current.isDateInToday(messageDate) {
            dateFormatter.dateFormat = "hh:mm a"
            time = dateFormatter.string(from: messageDate as Date)
        } else if Calendar.current.isDateInYesterday(messageDate) {
            time = "Yesterday"
        } else {
            dateFormatter.dateFormat = "MM/dd/yy"
            time = dateFormatter.string(from: messageDate as Date)
        }
//        let timeDifference = Calendar.current.dateComponents([.hour], from: messageDate, to: now)
//        let hour = Calendar.current.dateComponents([.hour], from: messageDate)
//        if let timeHourDifference = timeDifference.hour {
//            if timeHourDifference < 24 {
//                dateFormatter.dateFormat = "hh:mm a"
//                time = dateFormatter.string(from: messageDate as Date)
//            } else if timeHourDifference < 48 {
//                time = "Yesterday"
//            } else {
//                dateFormatter.dateFormat = "MM/dd/yy"
//                time = dateFormatter.string(from: messageDate as Date)
//            }
//        }
        return time
    }
}
