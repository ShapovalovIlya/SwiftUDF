//
//  ReducerDomain.swift
//  SwiftUDF
//
//  Created by User on 18.07.2023.
//

import Foundation
import Combine

public protocol ReducerDomain<State, Action> {
    associatedtype State
    associatedtype Action
    
    func reduce(_ state: inout State, action: Action) -> AnyPublisher<Action, Never>
    func run(_ action: Action) -> AnyPublisher<Action, Never>
    func run(_ actions: Action...) -> AnyPublisher<Action, Never>
    func empty() -> AnyPublisher<Action, Never>
}

public extension ReducerDomain {
    func run(_ action: Action) -> AnyPublisher<Action, Never> {
        Just(action).eraseToAnyPublisher()
    }
    
    func run(_ actions: Action...) -> AnyPublisher<Action, Never> {
        Publishers
            .MergeMany(actions.map(Just.init))
            .eraseToAnyPublisher()
    }
    
    func empty() -> AnyPublisher<Action, Never> {
        Empty().eraseToAnyPublisher()
    }
}
