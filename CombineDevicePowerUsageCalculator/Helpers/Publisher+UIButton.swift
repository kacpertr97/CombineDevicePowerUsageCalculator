//
//  Publisher+UIButton.swift
//  CombineDevicePowerUsageCalculator
//
//  Created by Kacper Trębacz on 24/03/2022.
//

import Foundation
import UIKit
import Combine

extension UIButton {
    func tapPublisher() -> AnyPublisher<Void, Never> {
        self.publisher(for: .touchUpInside)
            .map({ _ in
                return
            })
            .eraseToAnyPublisher()
    }
}
