//
//  Extensions.swift
//  Breeze
//
//  Created by HAIYING WENG on 8/13/19.
//  Copyright © 2019 Haiying Weng. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    func setLeftPadding(_ padding:CGFloat){
        let leftPadding = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.size.height))
        self.leftView = leftPadding
        self.leftViewMode = .always
    }
    func setRightPadding(_ padding:CGFloat) {
        let rightPadding = UIView(frame: CGRect(x: 0, y: 0, width: padding, height: self.frame.size.height))
        self.rightView = rightPadding
        self.rightViewMode = .always
    }
    
    func underline(){
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}

extension String {
    func allIndicesOf(substring: String) -> [Int] {
        var indices = [Int]()
        var searchIndex = self.startIndex
        
        while searchIndex < self.endIndex, let range = self.range(of: substring, range: searchIndex..<self.endIndex), !(range.isEmpty) {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchIndex = range.upperBound
        }
        return indices
    }
    
    func labelHeight(fontSize: CGFloat, labelWidth: CGFloat) -> CGFloat {
        var label: UILabel
        label = UILabel(frame: CGRect(x:0, y:0, width: labelWidth, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: fontSize)
        label.text = self
        label.sizeToFit()
        return label.frame.height

    }
}


extension UILabel {
    func changeColorOfSubstring(string: String, substring: String, color: UIColor) {
        let indices = string.lowercased().allIndicesOf(substring: substring.lowercased())
        let attributedText = NSMutableAttributedString(string: string)
        for index in indices {
            let range = NSRange(location: index, length: substring.count)
            attributedText.addAttribute(.foregroundColor, value: color, range: range)
        }
        self.attributedText = attributedText
    }
}

extension UIColor {
    static let baseBlue = UIColor(red:0.49, green:0.83, blue:0.97, alpha:1.0)
    static let darkerBlue = UIColor(red:0.05, green:0.58, blue:0.81, alpha:1.0)
    static let veryLightGray = UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.0)
}


let imageCache = NSCache<NSString,UIImage>()

extension UIImageView {
    
    func getImagesFromUrl(url: String) {
        
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: url as NSString) {
            self.image = cachedImage
            return
        }
        
        let imageUrl = URL(string: url)
        if let imageUrl = imageUrl {
            URLSession.shared.dataTask(with: imageUrl ) { (data, response, error) in
                if error != nil {
                    return
                }
                DispatchQueue.main.async {
                    if let downloadedImage = UIImage(data: data!) {
                        imageCache.setObject(downloadedImage, forKey: url as NSString)
                        self.image = downloadedImage
                    }
                }
                }.resume()
        }
        
    }
    
}
