//
//  DependencyContainer.swift
//  Movies Catalog
//
//  Created by Arman Gökalp on 29.08.2025.
//


// Simple DI container with singleton-scoped services for reuse and easy swapping in tests

import Foundation

protocol DependencyContainer {
    func register<T>(_ type: T.Type, factory: @escaping () -> T)
    func resolve<T>(_ type: T.Type) -> T
}

final class AppDependencyContainer: DependencyContainer {
    static let shared = AppDependencyContainer()
    
    private var services: [String: Any] = [:]
    private var factories: [String: () -> Any] = [:]
    
    private init() {}
    
    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        factories[key] = factory
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        let key = String(describing: type)
        
        if let service = services[key] as? T {
            return service
        }
        
        guard let factory = factories[key] else {
            fatalError("Service \(key) not registered")
        }
        
        let service = factory() as! T
        services[key] = service
        return service
    }
}

@propertyWrapper ///Clean syntax for DI
struct Injected<T> {
    private let container: DependencyContainer
    
    var wrappedValue: T {
        return container.resolve(T.self)
    }
    
    init(container: DependencyContainer = AppDependencyContainer.shared) {
        self.container = container
    }
}
