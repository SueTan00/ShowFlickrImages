//
//  LargeImageViewController.swift
//  ShowFlickrImg
//
//  Created by Sue Tan on 7/3/19.
//  Copyright © 2019 Sue Tan. All rights reserved.
//

import UIKit

class LargeImageViewController: UIViewController {

    @IBOutlet weak var largeImageView: UIImageView!
    
    var selectedImage:FlickrPhoto!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(selectedImage != nil){
            self.largeImageView.image = self.selectedImage.largeImage
        }
    }
}
