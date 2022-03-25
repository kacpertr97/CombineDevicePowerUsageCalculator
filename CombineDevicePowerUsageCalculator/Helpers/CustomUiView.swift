//
//  CustomUiView.swift
//  CombineDevicePowerUsageCalculator
//
//  Created by Kacper Trębacz on 25/03/2022.
//

import Foundation
import UIKit

class CustomUIView: UIView {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    func setup() {
        layer.cornerRadius = 25
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 3, height: 3)
        layer.shadowRadius = 5
        layer.shadowOpacity = 1
    }
}
