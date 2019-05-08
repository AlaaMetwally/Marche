//
//  CategoryCollectionViewCell.swift
//  Marche
//
//  Created by Geek on 5/5/19.
//  Copyright © 2019 Geek. All rights reserved.
//

import Foundation
import UIKit

class CategoryCollectionViewCell: UICollectionViewCell{
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    @IBAction func favoriteButton(_ sender: Any) {
        if(favoriteButton.tintColor == .red){
            favoriteButton.tintColor = .black
        }else{
            favoriteButton.tintColor = .red
        }
    }
}
