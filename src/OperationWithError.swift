//
//  OperationWithError.swift
//  SBJSON_test
//
//  Created by pawelc on 14/07/2018.
//  Copyright © 2018 MP. All rights reserved.
//

import Foundation

/// An interface for objects that report errors
public protocol ErrorReporting {
	/// Error or `nil` in case of no error
	var error : Error? { get }
}

/// Extends standard `Operation` with error handling and progress reporting
open class OperationWithError: Operation, ErrorReporting, ProgressReporting {
	
	/// ErrorReporting
	open var error : Error? {
		didSet {
			if let err = error {
				// check if is fatal error
				self.isErrorFatal = self.errorHandler(err)
			}
		}
	}
	
	open private(set) var isErrorFatal : Bool = false
	
	/// ProgressReporting
	open var progress : Progress
	
	/// Flag if an error was fatal, and should terminate execution
	/// or operation was cancelled
	/// - Remark: You should check this flag in your `main()` operation loop
	///	- Remark: Its value account for the `isCancelled` property
	open var shouldTerminate : Bool {
		return self.isCancelled || self.isErrorFatal
	}
	
	/// Return `true` if an error was fatal and should braek execution, `false` when the execution ca continue
	open var errorHandler : (Error) -> Bool = { (error) in
		return true	// all errors are fatal
	}
	
	public override init() {
		self.progress = Progress(totalUnitCount: 0)	// undeterminate
		
		super.init()
		
		self.progress.cancellationHandler = { [weak self] in
			self?.cancel()
		}
	}
	
	deinit {
		print( "deinit" )
	}
}

