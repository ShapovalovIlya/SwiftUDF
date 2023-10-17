//
//  Store.swift
//  SwiftUDF
//
//  Created by User on 16.07.2023.
//

import Foundation
import Combine
import OSLog

public typealias StoreOf<R: ReducerDomain> = Store<R.State, R.Action>

@dynamicMemberLookup
public final class Store<State, Action>: ObservableObject {
    @usableFromInline let reducer: any ReducerDomain<State, Action>
    @usableFromInline var cancellable: Set<AnyCancellable> = .init()
    @usableFromInline var logger: Logger?
    
    @Published public private(set) var state: State
    
    //MARK: - init(_:)
    public init<R: ReducerDomain>(
        state: R.State,
        reducer: R,
        logger: Logger? = nil
    ) where R.State == State, R.Action == Action {
        self.state = state
        self.reducer = reducer
        
        guard let logger = logger else {
            return
        }
           
        self.$state
            .map(String.init(describing:))
            .sink { logger.debug("\($0)") }
            .store(in: &cancellable)
    }
    
    //MARK: - Public methods
    public func send(_ action: Action) {
        logger?.debug("\(String(describing: action))")
        reducer.reduce(&state, action: action)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: send)
            .store(in: &cancellable)
    }
    
    @inlinable
    public func dispose() {
        cancellable.removeAll()
    }
    
    //MARK: - Subscript
    @inlinable
    public subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
        state[keyPath: keyPath]
    }
}

extension Store {
    public enum LogExhaustive {
        case none
        case all
        case state
        case action
    }
}
