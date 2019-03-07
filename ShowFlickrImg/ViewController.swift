//
//  ViewController.swift
//  ShowFlickrImg
//
//  Created by Sue Tan on 6/3/19.
//  Copyright © 2019 Sue Tan. All rights reserved.
//
import Foundation
import UIKit

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let reuseIdentifier = "Cell"
    private var searches: [FlickrPhoto] = []
    private var searchesOriginal: [FlickrPhoto]=[]
    private let flickr = FlickrHelper()
   
    func photo(for indexPath: IndexPath) -> FlickrPhoto {
        return searches[indexPath.row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //set searchBar delegate
        searchBar.becomeFirstResponder()
        searchBar.delegate = self
        // set collectionView delegate
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // initialize layout
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsets(top: 0,left: 5,bottom: 0,right: 5)
        layout.minimumInteritemSpacing = 5
        layout.itemSize = CGSize(width: (self.collectionView.frame.size.width - 20)/2,
                                 height: self.collectionView.frame.size.height/3)
        
        //Call FlickrHelper
        self.statusLabel.text = "Loading..."
        flickr.searchFlickr() { searchResults in
            switch searchResults {
            case .error(let error) :
                print("Error Searching: \(error)")
            case .results(let results):
                self.statusLabel.text = "Found \(results.count) images"
                self.searches=results
                self.searchesOriginal = self.searches
                self.collectionView?.reloadData()
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    //MARK:- CollectionView Datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searches.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        let flickrPhoto = photo(for: indexPath)
        cell.backgroundColor = .white
        cell.flickrImgView.image = flickrPhoto.thumbnail
        cell.flickrImgLabel.text = "ID: "+flickrPhoto.photoID
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.layer.borderWidth = 0.5
        return cell
    }
    
    //MARK:- CollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let largeImagePage:LargeImageViewController = self.storyboard?.instantiateViewController(withIdentifier: "LargeImageViewController") as! LargeImageViewController
        largeImagePage.selectedImage = self.photo(for: indexPath)
        self.navigationController?.pushViewController(largeImagePage, animated: true)
        
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.gray.cgColor
        cell?.layer.borderWidth = 2
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.borderColor = UIColor.lightGray.cgColor
        cell?.layer.borderWidth = 0.5
    }
    
    //MARK:- searchBar Delegate
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searches = self.searchesOriginal
        if(!(searchBar.text?.isEmpty)!){
            for (index, value) in searches.enumerated().reversed(){
                if (!value.title.containsIgnoringCase(find: searchBar.text!)){
                    searches.remove(at: index)
                }
            }
        }
        self.collectionView.reloadData()
        self.statusLabel.text = "Found \(searches.count) images"
    }
    
}
extension String{
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of:find, options: .caseInsensitive) != nil
    }
}
