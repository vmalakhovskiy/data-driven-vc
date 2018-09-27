//
//  Observable.swift
//  DataDrivenViewControllersUI
//
//  Created by Vitalii Malakhovskyi on 9/27/18.
//  Copyright © 2018 Vitalii Malakhovskyi. All rights reserved.
//

import Foundation

public class Observable<Value> {
    public internal(set) var value: Value
    
    public init(value: Value) {
        self.value = value
    }
    
    public func addObserver<O: AnyObject>(_ observer: O, using closure: @escaping (O, Value) -> Void) {}
    public func removeObserver<O: AnyObject>(_ observer: O) {}
}

public class Observer<Value>: Observable<Value> {
    private var observations = [ObjectIdentifier : (Value) -> Void]()
    
    public func update(with value: Value) {
        self.value = value
        
        for observation in observations.values {
            observation(value)
        }
    }
    
    override public func addObserver<O: AnyObject>(_ observer: O, using closure: @escaping (O, Value) -> Void) {
        let id = ObjectIdentifier(observer)
        observations[id] = { [weak self, weak observer] value in
            guard let observer = observer else {
                self?.observations[id] = nil
                return
            }
            
            closure(observer, value)
        }
        closure(observer, value)
    }
    
    override public func removeObserver<O: AnyObject>(_ observer: O) {
        let id = ObjectIdentifier(observer)
        observations.removeValue(forKey: id)
    }
}
