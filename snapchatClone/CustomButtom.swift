//
//  CustomButtom.swift
//  snapchatClone
//
//  Created by Forrest Collins on 3/13/16.
//  Copyright © 2016 Forrest Collins. All rights reserved.
//

import UIKit

class CustomButtom: UIButton {

    override func drawRect(rect: CGRect) {
        
        layer.cornerRadius = 5.0
        clipsToBounds = true
    }
}
