//
//  ReducerSpy.swift
//  BombTests
//
//  Created by Илья Шаповалов on 11.08.2023.
//

import Foundation
import Combine
import XCTest

public final class ReducerSpy<A: Equatable> {
    private var cancellable: Set<AnyCancellable> = .init()
    public private(set) var expectation: XCTestExpectation?
    public private(set) var actions: [A] = .init()
    
    public init(expectation: XCTestExpectation? = nil) {
        self.expectation = expectation
    }
    
    public func schedule(_ publishers: AnyPublisher<A, Never>...) {
        Publishers.MergeMany(publishers)
            .sink { _ in
                self.expectation?.fulfill()
            } receiveValue: { action in
                self.actions.append(action)
            }
            .store(in: &cancellable)
    }
}
