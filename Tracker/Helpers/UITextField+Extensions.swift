//
//  UITextField+Extensions.swift
//  Tracker
//
//  Created by Dmitry Markovskiy on 09.04.2024.
//

import UIKit

class CustomTextField: UITextField {
    override func clearButtonRect(forBounds bounds: CGRect) -> CGRect{
        let rect = super.clearButtonRect(forBounds: bounds)
        return rect.offsetBy(dx: -7, dy: 0)
    }
}
