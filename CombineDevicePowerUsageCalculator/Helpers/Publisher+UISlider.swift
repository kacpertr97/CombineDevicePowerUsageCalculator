//
//  Publisher+UISlider.swift
//  CombineDevicePowerUsageCalculator
//
//  Created by Kacper Trębacz on 24/03/2022.

import Foundation
import Combine
import UIKit

extension UISlider {

    func valuePublisher() -> AnyPublisher<Float, Never> {
        self.publisher(for: .valueChanged)
            .compactMap { ($0 as? UISlider)?.value }
            .eraseToAnyPublisher()
    }

    func createBinding<T: BinaryFloatingPoint>(with subject: CurrentValueSubject<T, Never>,
                                               storeIn subscriptions: inout Set<AnyCancellable>) {

        subject
            .map({ Float($0) })
            .sink { [weak self] (value) in
            if self?.value != value {
                self?.value = value
            }
        }.store(in: &subscriptions)

        self.valuePublisher()
            .map({ T($0) })
            .sink { (value) in
            if value != subject.value {
                subject.send(value)
            }
            }.store(in: &subscriptions)

    }
}
