//
//  Singleton.swift
//  Marche
//
//  Created by Geek on 5/8/19.
//  Copyright © 2019 Geek. All rights reserved.
//

import Foundation
class Singleton {
    
    var categories: [Category]? = [Category]()
    static let sharedInstance: Singleton = Singleton()
    
}
