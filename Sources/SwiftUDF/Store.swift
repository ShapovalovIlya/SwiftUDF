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
    private let reducer: any ReducerDomain<State, Action>
    private var cancellable: Set<AnyCancellable> = .init()
    private var logger: Logger?
    
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
        
        
    }
    
    //MARK: - Public methods
    public func send(_ action: Action) {
        logger?.debug("\(String(describing: action))")
        reducer.reduce(&state, action: action)
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: send)
            .store(in: &cancellable)
    }
    
    public func dispose() {
        cancellable.removeAll()
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<State, T>) -> T {
        state[keyPath: keyPath]
    }
}

private extension Store {
    
}

extension Store {
    public enum LogExhaustive {
        case none
        case all
        case state
        case action
    }
}
