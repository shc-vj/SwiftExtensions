//
//  Reference.swift
//  SBJSON_test
//
//  Created by pawelc on 12/07/2018.
//  Copyright © 2018 MP. All rights reserved.
//

import Foundation

final public class ReferenceTo<T:Any> {
	public var value : T
	
	init(_ any: T) {
		value = any
	}
}

final public class WeakReferenceTo<T:AnyObject> {
	public weak var value : T?
	
	init(_ anyObject: T) {
		value = anyObject
	}
}
