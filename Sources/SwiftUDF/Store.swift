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
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "Store<\(State.self)>"
    )
    private let reducer: any ReducerDomain<State, Action>
    private var cancellable: Set<AnyCancellable> = .init()
    
    @Published public private(set) var state: State
    
    //MARK: - init(_:)
    public init<R: ReducerDomain>(
        state: R.State,
        reducer: R
    ) where R.State == State, R.Action == Action {
        self.state = state
        self.reducer = reducer
    }
    
    //MARK: - Public methods
    public func send(_ action: Action) {
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
    
    public func logState() -> Self {
        self.$state
            .map(String.init(reflecting:))
            .sink { [weak self] in self?.logger.debug("\($0)") }
            .store(in: &self.cancellable)
        
        return self
    }
}
