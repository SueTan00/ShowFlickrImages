//
//  FlickrPhoto.swift
//  ShowFlickrImg
//
//  Created by Sue Tan on 6/3/19.
//  Copyright © 2019 Sue Tan. All rights reserved.
//

import Foundation
import UIKit

class FlickrPhoto: Equatable {
    
    var thumbnail:UIImage?
    var largeImage:UIImage?
    
    var photoID:String
    var farm:Int
    var server:String
    var secret:String
    var title:String
    
    init (photoID: String, farm: Int, server: String, secret: String, title: String) {
        self.photoID = photoID
        self.farm = farm
        self.server = server
        self.secret = secret
        self.title = title
        self.loadLargeImage { (result) in
            switch result {
            case .error(let error) :
                print("Error Searching: \(error)")
            case .results(let results):
                self.largeImage = results.largeImage
            }
        }
    }
    
    func flickrImageURL(_ size: String = "m") -> URL? {
        if let url =  URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_\(size).jpg") {
            return url
        }
        return nil
    }
    
    enum Error: Swift.Error {
        case invalidURL
        case noData
    }
    
    func loadLargeImage(completion: @escaping (Result<FlickrPhoto>) -> Void) {
        guard let loadURL = flickrImageURL("b") else {
            DispatchQueue.main.async {
                completion(Result.error(Error.invalidURL))
            }
            return
        }
        
        let loadRequest = URLRequest(url:loadURL)
        
        URLSession.shared.dataTask(with: loadRequest) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(Result.error(error))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(Result.error(Error.noData))
                }
                return
            }
            
            let returnedImage = UIImage(data: data)
            self.largeImage = returnedImage
            DispatchQueue.main.async {
                completion(Result.results(self))
            }
            }.resume()
    }
    
    static func ==(lhs: FlickrPhoto, rhs: FlickrPhoto) -> Bool {
        return lhs.photoID == rhs.photoID
    }
}
