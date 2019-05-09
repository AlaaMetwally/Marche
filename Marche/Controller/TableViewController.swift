//
//  TableViewController.swift
//  Marche
//
//  Created by Geek on 5/9/19.
//  Copyright © 2019 Geek. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    var dataController = DataController.shared
    var fetchedResultsController:NSFetchedResultsController<Favorite>!
    let fetchRequest:NSFetchRequest<Favorite> = Favorite.fetchRequest()

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchConfig()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchConfig()
        tableView.reloadData()
    }
    
    func fetchConfig(){
        let predicate = NSPredicate(format: "userEmail == %@", Singleton.sharedInstance.userEmail)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "titleEn", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(Singleton.sharedInstance.userEmail)-categories")
        
        fetchedResultsController.delegate = self
        do{
            try fetchedResultsController.performFetch()
        }catch{
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let favoriteItem = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath)
        cell.textLabel?.text = favoriteItem.titleEn
        // create url
        
        if let imageURL = URL(string: favoriteItem.photo ?? "") {
            // create network request
            let task = URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
                if error == nil {
                    // create image
                    let downloadedImage = UIImage(data: data!)
                    // update UI on a main thread
                    DispatchQueue.main.async{
                        cell.imageView?.image = downloadedImage
                    }
                } else {
                    print(error!)
                }
            }
            // start network request
            task.resume()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch (editingStyle) {
        case .delete:
            let favoriteItem = fetchedResultsController.object(at: indexPath)
            dataController.viewContext.delete(favoriteItem)
            try? dataController.viewContext.save()
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: tableView.insertSections(indexSet, with: .fade)
        case .delete: tableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
