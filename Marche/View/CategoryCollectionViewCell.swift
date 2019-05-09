//
//  CategoryCollectionViewCell.swift
//  Marche
//
//  Created by Geek on 5/5/19.
//  Copyright © 2019 Geek. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CategoryCollectionViewCell: UICollectionViewCell, NSFetchedResultsControllerDelegate{
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let fetchRequest:NSFetchRequest<Favorite> = Favorite.fetchRequest()
    var dataController = DataController.shared
    
    @IBAction func favoriteButton(_ sender: Any) {
        var attribute = ((sender as AnyObject).accessibilityIdentifier!)!
        var category = Singleton.sharedInstance.categories![Int(attribute)!]
        
        if(favoriteButton.tintColor == .red){
            favoriteButton.tintColor = .black
            let predicate = NSPredicate(format: " titleEn == %@", "\(category.titleEn)")
            fetchRequest.predicate = predicate
            if let result = try? dataController.viewContext.fetch(fetchRequest){
                for item in result{
                    dataController.viewContext.delete(item)
                    try? dataController.viewContext.save()
                }
            }
        }else{
            favoriteButton.tintColor = .red
            var favoriteCategories = Favorite(context: dataController.viewContext)
            favoriteCategories.photo = category.photo
            favoriteCategories.haveModel = category.haveModel
            favoriteCategories.productCount = category.productCount
            favoriteCategories.titleAr = category.titleAr
            favoriteCategories.titleEn = category.titleEn
            favoriteCategories.userEmail = Singleton.sharedInstance.userEmail
            try? dataController.viewContext.save()
        }
    }
}
