//
//  Category.swift
//  Marche
//
//  Created by Geek on 5/8/19.
//  Copyright © 2019 Geek. All rights reserved.
//

import Foundation

struct Category{
    var titleAr: String
    var titleEn: String
    var photo: String
    var productCount: String
    var haveModel: String
    var subCategories: [[String:AnyObject]]
    
    init(dictionary: [String:AnyObject]) {
        titleAr = dictionary["TitleAR"] as? String ?? ""
        titleEn = dictionary["TitleEN"] as? String ?? ""
        photo = dictionary["Photo"] as? String ?? ""
        productCount = dictionary["ProductCount"] as? String ?? ""
        haveModel = dictionary["HaveModel"] as? String ?? ""
        subCategories = dictionary["SubCategories"] as? [[String:AnyObject]] ?? []
    }
}
