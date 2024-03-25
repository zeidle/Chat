//
//  ChatPresenter.swift
//

import Foundation

// MARK: - ChatPresentationLogic

protocol ChatPresentationLogic {

	var viewController: ChatDisplayLogic? { get }

	func presentInitialMessages(with response: ChatModel.FetchMessage.Response)
	func presentOlderMessages(with response: ChatModel.FetchMessage.Response)
	func showRefreshControl()
	func hideRefreshControl()
}

// MARK: - ChatPresenter

final class ChatPresener: ChatPresentationLogic {

	// MARK: - Internal properties

	weak var viewController: ChatDisplayLogic?

	deinit {
		print("-- \(String(describing: Self.self)) deinit")
	}

	// MARK: - Internal methods

	func presentInitialMessages(with response: ChatModel.FetchMessage.Response) {
		let titles = response.values.map { String($0) }
		let viewModel = ChatModel.FetchMessage.ViewModel(cellTitles: titles)

		viewController?.reloadMessages(with: viewModel)
	}

	func presentOlderMessages(with response: ChatModel.FetchMessage.Response) {

		let titles = response.values.map { String($0) }
		let viewModel = ChatModel.FetchMessage.ViewModel(cellTitles: titles)

		viewController?.addOlderMessages(with: viewModel)
	}

	func showRefreshControl() {
		viewController?.showRefreshControl()
	}

	func hideRefreshControl() {
		viewController?.hideRefreshControl()
	}
}
