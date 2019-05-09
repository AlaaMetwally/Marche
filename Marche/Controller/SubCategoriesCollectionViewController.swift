//
//  SubCategoriesCollectionViewController.swift
//  Marche
//
//  Created by Geek on 5/6/19.
//  Copyright © 2019 Geek. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SubCategoriesCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{
    
    var subCategories: [[String:AnyObject]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCategoryCell", for: indexPath) as! subCategoryViewCell
        let indexItem = subCategories[indexPath.row]
        let imageURL = URL(string: indexItem["Photo"] as! String)
        let task = URLSession.shared.dataTask(with: imageURL!) { (data, response, error) in
            if error == nil {
                // create image
                let downloadedImage = UIImage(data: data!)
                // update UI on a main thread
                DispatchQueue.main.async{
                    cell.categoryLabel.text = "( \(indexItem["ProductCount"]!) ) \(indexItem["TitleEN"]!)"
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
