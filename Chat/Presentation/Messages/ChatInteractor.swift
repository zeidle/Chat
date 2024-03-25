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
		static let messagesBatchSize = 20
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

		networkWorker.fetchMessages(offset: 0, limit: Constant.messagesBatchSize) { [weak self] result in
			guard let self else { return }

			let response = ChatModel.FetchMessage.Response(values: result)
			self.presenter?.presentInitialMessages(with: response)

			self.isRefreshing = false
			self.loadedAllMessages = result.count < Constant.messagesBatchSize
		}
	}

	func fetchOlderMessages() {
		guard !isRefreshing, !loadedAllMessages else { return }

		presenter?.showRefreshControl()
		
		let newCurrentMessagesOffset = self.currentMessagesOffset + Constant.messagesBatchSize

		isRefreshing = true
		networkWorker.fetchMessages(offset: newCurrentMessagesOffset, limit: Constant.messagesBatchSize) { [weak self] result in
			guard let self else { return }

			self.loadedAllMessages = result.count < Constant.messagesBatchSize

			self.currentMessagesOffset += newCurrentMessagesOffset

			let response = ChatModel.FetchMessage.Response(values: result)

			self.presenter?.presentOlderMessages(with: response)

			self.presenter?.hideRefreshControl()

			self.isRefreshing = false
		}
	}

	func messagesDidScroll(request: ChatModel.TableMessagesInfo.Request) {

		let contentOffset = request.contentOffset
		let visibleSize = request.visibleSize

		let needToFetch = contentOffset.y <= visibleSize.height

		guard needToFetch else { return }

		fetchOlderMessages()
	}
}
