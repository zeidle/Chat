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

	typealias Response = ChatModel.FetchMessage.Response

	weak var viewController: ChatDisplayLogic?

	deinit {
		print("-- \(String(describing: Self.self)) deinit")
	}

	// MARK: - Internal methods

	func presentInitialMessages(with response: Response) {

		let response = convertToViewModel(response)

		viewController?.reloadMessages(with: response)
	}

	func presentOlderMessages(with response: Response) {

		let response = convertToViewModel(response)

		viewController?.addOlderMessages(with: response)
	}

	func showRefreshControl() {
		viewController?.showRefreshControl()
	}

	func hideRefreshControl() {
		viewController?.hideRefreshControl()
	}
}

private extension ChatPresener {

	func convertToViewModel(_ response: Response) -> ChatViewController.ViewModel {
		typealias MessageGroup =  ChatModel.FetchMessage.ViewModel.MessageGroup

		let messageGroups: [MessageGroup] = response.messages.map {
			MessageGroup(date: $0, messages: $1)
		}
		return .init(messageGroups: messageGroups)
	}
}
