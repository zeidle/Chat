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

	func convertToViewModel(_ response: Response) -> ChatModel.FetchMessage.ViewModel {
		typealias MessageGroup = ChatModel.MessagesGroup

		let messageGroups: [MessageGroup] = response.messagesGroups.map {
			MessageGroup(date: $0.key, messages: $0.value)
		}
		return .init(messageGroups: messageGroups)
	}
}
