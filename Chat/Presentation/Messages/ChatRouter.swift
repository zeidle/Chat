//
//  ChatRouter.swift
//

import UIKit

// MARK: - ChatRoutingLogic

protocol ChatRoutingLogic: AnyObject {

	var viewController: ChatDisplayLogic? { get }

	func close()
}
// MARK: - ChatDataPassing

protocol ChatDataPassing: AnyObject {
	var dataStore: ChatDataStore? { get }
}

// MARK: - ChatRouter

final class ChatRouter: ChatDataPassing {

	// MARK: - Internal properties

	weak var viewController: ChatDisplayLogic?
	var dataStore: ChatDataStore?

	deinit {
		print("-- \(String(describing: Self.self)) deinit")
	}

	// MARK: - Internal properties

	// TODO: - Some actions
}

// MARK: - ChatRoutingLogic

extension ChatRouter: ChatRoutingLogic {
	func close() {
		self.viewController?.dismiss(animated: true)
	}
}

// MARK: Private ChatRouter

private extension ChatRouter {

	// MARK: Navigation

//	func navigateToSomewhere(source: ChatViewController, destination: ) {
//			// TODO: - some actions
//			source.show(destination, sender: nil)
//	}
//
//	// MARK: Passing data
//
//	func passDataToSomewhere(source: ChatDataStore, destination: inout <#DestionationDataStore#>) {
//		// TODO: - some action
//	}
}
