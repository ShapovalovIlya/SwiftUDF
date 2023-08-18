//
//  ReducerSpy.swift
//  BombTests
//
//  Created by Илья Шаповалов on 11.08.2023.
//

import Foundation
import Combine
// import XCTest

public final class ReducerSpy<A: Equatable> {
    private var cancellable: Set<AnyCancellable> = .init()
//    let exp = XCTestExpectation(description: "ReducerSpy")
    public private(set) var actions: [A] = .init()
    
    init() { }
    
    func schedule(_ publishers: AnyPublisher<A, Never>...) {
        Publishers.MergeMany(publishers)
            .sink { _ in
    //            self.exp.fulfill()
            } receiveValue: { action in
                self.actions.append(action)
            }
            .store(in: &cancellable)
    }
}
