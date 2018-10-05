//
//  Extensions.swift
//  Text-App
//
//  Created by Yash Ganorkar on 10/4/18.
//  Copyright © 2018 Yash Ganorkar. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, AnyObject>()

extension UIImageView {
    func loadImageUsingCache(withURL urlString : String) {
        
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage{
            self.image = cachedImage
            return
        }
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!) { (data, response, err) in
            
            guard let data = data, err == nil else { return }
            print(response?.suggestedFilename ?? url!.lastPathComponent)
            print("Download Finished")
            DispatchQueue.main.async() {
                if let downloadedImage = UIImage(data: data){
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = downloadedImage
                }
            }
        }.resume()
    }
}

extension NSLayoutConstraint {
    
    override open var description: String {
        let id = identifier ?? ""
        return "id: \(id), constant: \(constant)" //you may print whatever you want here
    }
}
