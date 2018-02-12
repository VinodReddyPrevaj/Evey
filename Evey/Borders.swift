//
//  Cat.swift
//  EveyDemo
//
//  Created by PROJECTS on 10/10/17.
//  Copyright © 2017 Prevaj. All rights reserved.
//

import UIKit

extension CALayer {
    var borderUIColor: UIColor {
        set {
            self.borderColor = newValue.cgColor
        }
        
        get {
            return UIColor(cgColor: self.borderColor!)
        }
    }
}
extension UIPreviewAction {
    
    var tintColor: UIColor? {
        get {
            return value(forKey: "_color") as? UIColor
        }
        set {
            setValue(newValue, forKey: "_color")
        }
    }
    
}

