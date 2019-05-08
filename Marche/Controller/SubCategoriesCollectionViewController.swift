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

class SubCategoriesCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate{
    
    var category: Category?
    var fetchedResultsController:NSFetchedResultsController<Category>!
    let fetchRequest:NSFetchRequest<Category> = Category.fetchRequest()
    let dataController = DataController.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sortDescriptor = NSSortDescriptor(key: "titleEn", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        guard let allCategories = try? dataController.viewContext.fetch(fetchRequest) else { return }
        print(allCategories)
        let result = allCategories.filter {
            
            if ($0.categories == category?.categories){
//                print($0.categories)
                return true
            }
            return true }
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "category-album")
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubCategoryCell", for: indexPath) as! subCategoryViewCell
//        let indexItem = subCategories?.allObjects.index(after: indexPath.item - 1)
        
//        let imageURL = URL(string: indexItem!["photo"])
//        let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
//            if error == nil {
//                // create image
//                let downloadedImage = UIImage(data: data!)
//                // update UI on a main thread
//                DispatchQueue.main.async{
//                    cell.categoryLabel.text = "( \(indexItem.productCount!) ) \(indexItem.titleEn!)"
//                    if (downloadedImage == nil){
//                        cell.categoryImage.image = UIImage(named: "cat_no_img.png")
//                    }else{
//                        cell.categoryImage.image = downloadedImage
//                    }
//                }
//            } else {
//                print(error!)
//            }
//        }
//        // start network request
//        task.resume()
        return cell
    }
    
}
