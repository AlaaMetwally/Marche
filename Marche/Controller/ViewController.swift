//
//  ViewController.swift
//  Marche
//
//  Created by Geek on 5/5/19.
//  Copyright © 2019 Geek. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class ViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var fetchedResultsController:NSFetchedResultsController<Category>!
    let fetchRequest:NSFetchRequest<Category> = Category.fetchRequest()
    let dataController = DataController.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        addNavBarImage()
        UIApplication.shared.registerForRemoteNotifications()
        let sortDescriptor = NSSortDescriptor(key: "titleEn", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "category-album")
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func addNavBarImage() {
    
        let image = #imageLiteral(resourceName: "top_bar_logo")
        let imageView = UIImageView(image: image)
        
        let bannerWidth = navigationController!.navigationBar.frame.size.width
        let bannerHeight = navigationController!.navigationBar.frame.size.height
        
        let bannerX = bannerWidth / 2 - image.size.width / 2
        let bannerY = bannerHeight / 2 - image.size.height / 2
        
        imageView.frame = CGRect(x: bannerX, y: bannerY, width: bannerWidth, height: bannerHeight)
        imageView.contentMode = .scaleAspectFit
        
        navigationItem.titleView = imageView
        
        let img = UIImage(named: "top_bar_bg.png")
        navigationController!.navigationBar.setBackgroundImage(img,
                                                               for: .default)
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCollectionViewCell
        cell.favoriteButton.tintColor = .black
        
        let indexItem = fetchedResultsController.object(at: indexPath)
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "SubCategoriesCollectionViewController") as! SubCategoriesCollectionViewController
        let indexItem = fetchedResultsController.object(at: indexPath)
        detailController.category = indexItem
        self.navigationController!.pushViewController(detailController, animated: true)
        
    }
    
}

