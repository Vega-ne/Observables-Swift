//
//  ObservableProxy.swift
//  Observables-Swift
//
//  Created by Leszek Ślażyński on 24/06/14.
//  Copyright (c) 2014 Leszek Ślażyński. All rights reserved.
//

// two generic parameters are needed to be able to override `value` in `ObservableReference<T>`

public class ObservableProxy<T, O: AnyObservable where O.ValueType == T> : OwnableObservable {
    
    public typealias ValueType = T
    
    public /*internal(set)*/ var beforeChange = EventReference<ValueChange<T>>()
    public /*internal(set)*/ var afterChange = EventReference<ValueChange<T>>()
    
    // private storage in case subclasses override value with a setter
    private var _value : T
    
    public var value : T {
        return _value
    }
    
    public init (_ o : O) {
        self._value = o.value
        o.beforeChange.add(owner: self) { [weak self] change in
            self!.beforeChange.notify(change)
        }
        o.afterChange.add(owner: self) { [weak self] change in
            let nV = change.newValue
            self!._value = nV
            self!.afterChange.notify(change)
        }
    }
    
}

public func proxy <O: AnyObservable> (o: O) -> ObservableProxy<O.ValueType, O> {
    return ObservableProxy(o)
}
