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
public protocol LazyValueType : class {
	associatedtype ValueType
	associatedtype BoxedComputation

	var _value: LazyValueBox<ValueType, BoxedComputation> { get set }
}


/// Lazy value type that can be resetted into `.notComputed` state
public protocol ResetableLazyValueType : LazyValueType {
	var computation : BoxedComputation { get set }
	
	func reset()
}

public extension ResetableLazyValueType {
	public func reset() {
		_value = LazyValueBox.notComputed(computation)
	}
}

public extension LazyValueType where BoxedComputation==() -> ValueType {
	public var value : ValueType {
		switch _value {
		case .computed(let val):
			return val
		case .notComputed(let compute):
			let value = compute()
			_value = .computed(value)
			return value
			
		default:
			fatalError("Can never reach this")
		}
	}
}

public extension LazyValueType where BoxedComputation==() throws -> ValueType {
	
	public var error : Error? {
		switch _value {
		case .error(let err):
			return err
		default:
			return nil
		}
	}
	
	public func tryValue() throws -> ValueType {
		switch _value {
		case .computed(let val):
			return val
		case .notComputed(let compute):
			do {
				let value = try compute()
				_value = .computed(value)
				return value
			} catch {
				_value = .error(error)
				throw error
			}
			
		case .error(let err):
			throw err
		}
	}
}

public class LazyValueGeneric<ValueType,BoxedComputation> : LazyValueType {
	
	public var _value: LazyValueBox<ValueType, BoxedComputation>
	
	public init(_ block : BoxedComputation ) {
		_value = LazyValueBox.notComputed(block)
	}
}

// MARK: -

/**
	Implementation of lazy evaluation.

	Once is evaluated, stays immutable, computation block is released
*/
public typealias LazyValue<ValueType> = LazyValueGeneric<ValueType,() -> ValueType>

/**
	Implementation of lazy throwable evaluation.

	Once is evaluated, stays immutable, computation block is released
*/
public typealias LazyThrowableValue<ValueType> = LazyValueGeneric<ValueType,() throws ->ValueType>

/**
	Implementation of lazy evaluation.

	Once is evaluated, stays immutable, strong reference to a computation block is held
*/
public class LazyResetableValue<ValueType> : LazyValue<ValueType>, ResetableLazyValueType {

	public var computation: BoxedComputation

	public override init(_ block: @escaping BoxedComputation) {
		self.computation = block
		super.init(block)
	}
}

/**
Implementation of lazy throwable evaluation.

Once is evaluated, stays immutable, strong reference to a computation block is held
*/
public class LazyResetableThrowableValue<ValueType> : LazyThrowableValue<ValueType>, ResetableLazyValueType {
	
	public var computation: BoxedComputation

	public override init(_ block: @escaping BoxedComputation) {
		self.computation = block
		super.init(block)
	}
}

