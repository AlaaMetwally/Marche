//
//  TabBarController.swift
//  Marche
//
//  Created by Geek on 5/9/19.
//  Copyright © 2019 Geek. All rights reserved.
//

import Foundation
import UIKit

class TabBarController: UITabBarController{
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addNavBarImage()
    }
    
    @IBAction func logout(_ sender: Any) {
        DispatchQueue.main.async{
            self.dismiss(animated: true, completion: nil)
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
