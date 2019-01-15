//
//  LazyBox.swift
//  SBJSON_test
//
//  Created by pawelc on 14/07/2018.
//  Copyright © 2018 MP. All rights reserved.
//

import Foundation


public enum LazyValueBox<ValueType,Compute> {
	case notComputed(Compute)
	case computed(ValueType)
	case error(Error)
}


/// Lazy value type
public protocol LazyValuable  {
	associatedtype ValueType
	associatedtype BoxedComputation

	var _valueBox: LazyValueBox<ValueType, BoxedComputation> { get set }
}

public extension LazyValuable where BoxedComputation==() -> ValueType {
	public var value : ValueType {
		mutating get {
			switch _valueBox {
			case .computed(let val):
				return val
			case .notComputed(let compute):
				let value = compute()
				_valueBox = .computed(value)
				return value
				
			default:
				fatalError("Can never reach this")
			}
		}
	}
}

public extension LazyValuable where BoxedComputation==() throws -> ValueType {
	
	public var error : Error? {
		switch _valueBox {
		case .error(let err):
			return err
		default:
			return nil
		}
	}
	
	public mutating func tryValue() throws -> ValueType {
		switch _valueBox {
		case .computed(let val):
			return val
		case .notComputed(let compute):
			do {
				let value = try compute()
				_valueBox = .computed(value)
				return value
			} catch {
				_valueBox = .error(error)
				throw error
			}
			
		case .error(let err):
			throw err
		}
	}
}

/// Lazy value type that can be resetted into `.notComputed` state
public protocol ResetableLazyValuable : LazyValuable {
	var computation : BoxedComputation { get }
	
	mutating func reset()
}

public extension ResetableLazyValuable {
	public mutating func reset() {
		_valueBox = LazyValueBox.notComputed(computation)
	}
}


// MARK: -

/**
	Implementation of lazy evaluation.

	Once is evaluated, stays immutable, computation block is released
*/
public class LazyValue<ValueType> : LazyValuable {
	public typealias BoxedComputation = () -> ValueType
	
	public var _valueBox: LazyValueBox<ValueType, BoxedComputation>
	
	public init(_ block : @escaping BoxedComputation ) {
		_valueBox = LazyValueBox<ValueType,BoxedComputation>.notComputed(block)
	}
}

/**
	Implementation of lazy throwable evaluation.

	Once is evaluated, stays immutable, computation block is released
*/
public class LazyThrowableValue<ValueType> : LazyValuable {
	public typealias BoxedComputation = () throws -> ValueType

	public var _valueBox: LazyValueBox<ValueType, BoxedComputation>
	
	public init(_ block : @escaping BoxedComputation ) {
		_valueBox = LazyValueBox<ValueType,BoxedComputation>.notComputed(block)
	}
}

/**
	Implementation of lazy evaluation.

	Once is evaluated, stays immutable, strong reference to a computation block is held
*/
public class LazyResetableValue<ValueType> : LazyValue<ValueType>, ResetableLazyValuable {
	public var computation: BoxedComputation

	override public init(_ block: @escaping BoxedComputation) {
		computation = block
		super.init(block)
	}
}

/**
Implementation of lazy throwable evaluation.

Once is evaluated, stays immutable, strong reference to a computation block is held
*/
public class LazyResetableThrowableValue<ValueType> : LazyThrowableValue<ValueType>, ResetableLazyValuable {
	
	public var computation: BoxedComputation
	
	override public init(_ block: @escaping BoxedComputation) {
		computation = block
		super.init(block)
	}
}

