//
//  CustomTextField.swift
//  snapchatClone
//
//  Created by Forrest Collins on 3/13/16.
//  Copyright © 2016 Forrest Collins. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {

    //-----------------------
    // MARK: - Awake from Nib
    //-----------------------
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 5.0
    }
    
    // For placeholder, the rectangle you want the text in
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        let leftValue: CGFloat = 14
        return CGRectInset(bounds, leftValue, 0)
    }
    
    // For editable text, the rectangle you want the text in
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        let leftValue: CGFloat = 14
        return CGRectInset(bounds, leftValue, 0)
    }
}
