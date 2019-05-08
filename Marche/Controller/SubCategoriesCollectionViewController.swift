//
//  SubCategoriesCollectionViewController.swift
//  Marche
//
//  Created by Geek on 5/6/19.
//  Copyright © 2019 Geek. All rights reserved.
//

import Foundation
import UIKit

class SubCategoriesCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    var subCategories: [Category]? = [Category]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (subCategories?.count)!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCategoryCell", for: indexPath) as! subCategoryViewCell
        
        let indexItem = subCategories![indexPath.item]
        let imageURL = URL(string: indexItem.photo!)!
        let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            if error == nil {
                // create image
                let downloadedImage = UIImage(data: data!)
                // update UI on a main thread
                DispatchQueue.main.async{
                    cell.categoryLabel.text = "( \(indexItem.productCount!) ) \(indexItem.titleEn!)"
                    if (downloadedImage == nil){
                        cell.categoryImage.image = UIImage(named: "cat_no_img.png")
                    }else{
                        cell.categoryImage.image = downloadedImage
                    }
                }
            } else {
                print(error!)
            }
        }
        // start network request
        task.resume()
        return cell
    }
    
}
