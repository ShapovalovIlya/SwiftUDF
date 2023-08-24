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
        category: "StoreOf<\(State.self)>"
    )
    private let reducer: any ReducerDomain<State, Action>
    private var cancellable: Set<AnyCancellable> = .init()
    private let logExhaustive: LogExhaustive
    
    @Published public private(set) var state: State
    
    //MARK: - init(_:)
    public init<R: ReducerDomain>(
        state: R.State,
        reducer: R,
        logExhaustive: LogExhaustive = .none
    ) where R.State == State, R.Action == Action {
        self.state = state
        self.reducer = reducer
        self.logExhaustive = logExhaustive
        
        switch logExhaustive {
        case .all, .state: logState()
        default: break
        }
    }
    
    //MARK: - Public methods
    public func send(_ action: Action) {
        switch logExhaustive {
        case .all, .action: logger.debug("\(String(describing: action))")
        default: break
        }
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
    func log(content: String) {
        logger.debug("\(content)")
    }
    
    func logState() {
        self.$state
            .map(String.init(describing:))
            .sink(receiveValue: log(content:))
            .store(in: &cancellable)
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
