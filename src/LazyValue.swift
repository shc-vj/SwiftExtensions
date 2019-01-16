//
//  LazyBox.swift
//  SBJSON_test
//
//  Created by pawelc on 14/07/2018.
//  Copyright © 2018 MP. All rights reserved.
//

import Foundation


public enum LazyValueBox<Value,Computation> {
	case notComputed(Computation)
	case computed(Value)
	case error(Error)
}


/// Lazy value type
public protocol LazyValuable  {
	associatedtype Value
	associatedtype Computation

	var _boxedValue: LazyValueBox<Value, Computation> { get set }
}

public extension LazyValuable where Computation==() -> Value {
	public var value : Value {
		mutating get {
			switch _boxedValue {
			case .computed(let val):
				return val
			case .notComputed(let compute):
				let value = compute()
				_boxedValue = .computed(value)
				return value
				
			default:
				fatalError("Can never reach this")
			}
		}
	}
}

public extension LazyValuable where Computation==() throws -> Value {
	
	public var error : Error? {
		switch _boxedValue {
		case .error(let err):
			return err
		default:
			return nil
		}
	}
	
	public mutating func tryValue() throws -> Value {
		switch _boxedValue {
		case .computed(let val):
			return val
		case .notComputed(let compute):
			do {
				let value = try compute()
				_boxedValue = .computed(value)
				return value
			} catch {
				_boxedValue = .error(error)
				throw error
			}
			
		case .error(let err):
			throw err
		}
	}
}

/// Lazy value type that can be resetted into `.notComputed` state
public protocol ResetableLazyValuable : LazyValuable {
	var computation : Computation { get }
	
	mutating func reset()
}

public extension ResetableLazyValuable {
	public mutating func reset() {
		_boxedValue = LazyValueBox.notComputed(computation)
	}
}


// MARK: -

/**
	Implementation of lazy evaluation.

	Once is evaluated, stays immutable, computation block is released
*/
public class LazyValue<ValueType> : LazyValuable {
	public typealias Computation = () -> ValueType
	
	public var _boxedValue: LazyValueBox<ValueType, Computation>
	
	public init(_ block : @escaping Computation ) {
		_boxedValue = LazyValueBox<ValueType,Computation>.notComputed(block)
	}
}

/**
	Implementation of lazy throwable evaluation.

	Once is evaluated, stays immutable, computation block is released
*/
public class LazyThrowableValue<ValueType> : LazyValuable {
	public typealias Computation = () throws -> ValueType

	public var _boxedValue: LazyValueBox<ValueType, Computation>
	
	public init(_ block : @escaping Computation ) {
		_boxedValue = LazyValueBox<ValueType,Computation>.notComputed(block)
	}
}

/**
	Implementation of lazy evaluation.

	Once is evaluated, stays immutable, strong reference to a computation block is held
*/
public class LazyResetableValue<ValueType> : LazyValue<ValueType>, ResetableLazyValuable {
	public var computation: Computation

	override public init(_ block: @escaping Computation) {
		computation = block
		super.init(block)
	}
}

/**
Implementation of lazy throwable evaluation.

Once is evaluated, stays immutable, strong reference to a computation block is held
*/
public class LazyResetableThrowableValue<ValueType> : LazyThrowableValue<ValueType>, ResetableLazyValuable {
	
	public var computation: Computation
	
	override public init(_ block: @escaping Computation) {
		computation = block
		super.init(block)
	}
}

