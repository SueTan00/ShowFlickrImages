//
//  FlickrHelper.swift
//  ShowFlickrImg
//
//  Created by Sue Tan on 6/3/19.
//  Copyright © 2019 Sue Tan. All rights reserved.
//

import Foundation
import UIKit

class FlickrHelper {
    
    enum Error: Swift.Error {
        case unknownAPIResponse
        case generic
    }
    
    private func getURLForRecentPhotos() -> URL?{
        let apiKey = "874a73bd8cb2b621d6dd3bd4178e7fd7"
        let URLString = "https://api.flickr.com/services/rest/?method=flickr.photos.getRecent&api_key=\(apiKey)&format=json&nojsoncallback=1"
        return URL(string: URLString)
    }
    
    func searchFlickr(completion: @escaping (Result<[FlickrPhoto]>) -> Void) {
        guard let searchURL = getURLForRecentPhotos() else {
            completion(Result.error(Error.unknownAPIResponse))
            return
        }
        
        let searchRequest = URLRequest(url: searchURL)
        
        URLSession.shared.dataTask(with: searchRequest) { (data, response, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(Result.error(error))
                }
                return
            }
            
            guard
                let _ = response as? HTTPURLResponse,
                let data = data
                else {
                    DispatchQueue.main.async {
                        completion(Result.error(Error.unknownAPIResponse))
                    }
                    return
            }
            
            do {
                guard
                    let resultsDictionary = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject],
                    let stat = resultsDictionary["stat"] as? String
                    else {
                        DispatchQueue.main.async {
                            completion(Result.error(Error.unknownAPIResponse))
                        }
                        return
                }
                
                switch (stat) {
                case "ok":
                    print("Results processed OK")
                case "fail":
                    DispatchQueue.main.async {
                        completion(Result.error(Error.generic))
                    }
                    return
                default:
                    DispatchQueue.main.async {
                        completion(Result.error(Error.unknownAPIResponse))
                    }
                    return
                }
                
                guard
                    let photosContainer = resultsDictionary["photos"] as? [String: AnyObject],
                    let photosReceived = photosContainer["photo"] as? [[String: AnyObject]]
                    else {
                        DispatchQueue.main.async {
                            completion(Result.error(Error.unknownAPIResponse))
                        }
                        return
                }
                
                let flickrPhotos: [FlickrPhoto] = photosReceived.compactMap { photoObject in
                    guard
                        let photoID = photoObject["id"] as? String,
                        let farm = photoObject["farm"] as? Int ,
                        let server = photoObject["server"] as? String ,
                        let secret = photoObject["secret"] as? String ,
                        let title = photoObject["title"] as? String
                        else {
                            return nil
                    }
                    
                    let flickrPhoto = FlickrPhoto(photoID: photoID, farm: farm, server: server, secret: secret, title: title)
                    
                    guard
                        let url = flickrPhoto.flickrImageURL(),
                        let imageData = try? Data(contentsOf: url as URL)
                        else {
                            return nil
                    }
                    
                    if let image = UIImage(data: imageData) {
                        flickrPhoto.thumbnail = image
                        return flickrPhoto
                    } else {
                        return nil
                    }
                }
                
                DispatchQueue.main.async {
                    completion(Result.results(flickrPhotos))
                }
            } catch {
                completion(Result.error(error))
                return
            }
            }.resume()
    }
}
