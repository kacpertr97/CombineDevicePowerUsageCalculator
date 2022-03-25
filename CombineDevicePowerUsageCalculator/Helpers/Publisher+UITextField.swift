//
//  Publisher+UITextField.swift
//  CombineDevicePowerUsageCalculator
//
//  Created by Kacper Trębacz on 24/03/2022.
//

import Foundation
import UIKit
import Combine

extension UITextField {

    func textPublisher() -> AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .compactMap({ ($0.object as? UITextField)?.text })
            .eraseToAnyPublisher()
    }

    func createBinding(with subject: CurrentValueSubject<String, Never>,
                       storeIn subscriptions: inout Set<AnyCancellable>) {

        subject.sink { [weak self] (value) in
            if value != self?.text {
                self?.text = value
            }
        }.store(in: &subscriptions)

        self.textPublisher().sink { (value) in
            if value != subject.value {
                subject.send(value)
            }
        }.store(in: &subscriptions)
    }
}
