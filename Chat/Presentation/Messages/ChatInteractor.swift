//
//  ChatInteractor.swift
//

import Foundation

// MARK: - ChatRoutingLogic

protocol ChatBusinessLogic: AnyObject {

	var presenter: ChatPresentationLogic? { get }

	func viewDidLoad()

	func fetchOlderMessages()
	func messagesDidScroll(request: ChatModel.TableMessagesInfo.Request)
}

// MARK: - ChatDataStore

protocol ChatDataStore: AnyObject {

	// TODO: - some properties
}

// MARK: - ChatInteractor

class ChatInteractor: ChatDataStore {

	enum Constant {
		static let messagesBatchSize = 10
	}
	// MARK: - Private properties

	private var networkWorker = ChatNetworkWorker()
	private var currentMessagesOffset = 0
	private var isRefreshing = false
	private var loadedAllMessages: Bool = false

	// MARK: - Internal properties

	var presenter: ChatPresentationLogic?

	deinit {
		print("-- \(String(describing: Self.self)) deinit")
	}
}

// MARK: - ChatBusinessLogic

extension ChatInteractor: ChatBusinessLogic {

	func viewDidLoad() {
		// TODO: - some actions
		fetchInitialMessages()
	}

	func fetchInitialMessages() {
		guard !isRefreshing else { return }

		isRefreshing = true
		currentMessagesOffset = 0

		Task(priority: .medium) {

			let limit = Constant.messagesBatchSize

			let messages: [ApiMessage] = await networkWorker
				.fetchMessages(offset:0, limit: limit)

			let response = convertToResponse(messages)

			loadedAllMessages = messages.count < Constant.messagesBatchSize

			presenter?.presentInitialMessages(with: response)

			isRefreshing = false
		}
	}

	func fetchOlderMessages() {

		presenter?.showRefreshControl()
		
		let limit = Constant.messagesBatchSize
		let newCurrentMessagesOffset = currentMessagesOffset + limit

		isRefreshing = true
		Task(priority: .background) {
			let messages: [ApiMessage] = await networkWorker
				.fetchMessages(offset:newCurrentMessagesOffset, limit: limit)
			self.currentMessagesOffset += newCurrentMessagesOffset

			self.loadedAllMessages = messages.count < Constant.messagesBatchSize

			let response = convertToResponse(messages)

			self.presenter?.presentOlderMessages(with: response)

			self.presenter?.hideRefreshControl()

			self.isRefreshing = false
		}
	}

	func messagesDidScroll(request: ChatModel.TableMessagesInfo.Request) {

		let contentOffset = request.contentOffset
		let visibleSize = request.visibleSize

		let needToFetch = contentOffset.y <= visibleSize.height

		guard needToFetch, !isRefreshing, !loadedAllMessages else { return }

		fetchOlderMessages()
	}

	func convertToResponse(_ messages: [ApiMessage]) -> ChatModel.FetchMessage.Response {
		let messages = messages.map { ChatModel.Message(apiModel: $0) }
		let messagesGroups = Dictionary(grouping: messages) { $0.date }

		return .init(messagesGroups: messagesGroups)
	}
}
