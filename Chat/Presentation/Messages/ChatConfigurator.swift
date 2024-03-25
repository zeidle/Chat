//
//  ChatConfigurator.swift
//

import Foundation

// MARK: - ChatConfiguratorProtocol

protocol ChatConfiguratorProtocol: AnyObject {
	static func makeScreen() -> ChatDisplayLogic
}

// MARK: - ChatConfigurator

final class ChatConfigurator: ChatConfiguratorProtocol {

	private init() {}

	// MARK: -  Private properties
	static func makeScreen() -> ChatDisplayLogic {
		let controller = ChatViewController()
		let router = ChatRouter()
		let interactor = ChatInteractor()
		let presenter = ChatPresener()

		controller.router = router
		controller.interactor = interactor
		router.viewController = controller
		interactor.presenter = presenter
		presenter.viewController = controller

		return controller
	}
}
