//
//  ChatModels.swift
//

// MARK: - Chat
import Foundation

enum ChatModel {

	enum TableMessagesInfo {
		struct Request {
			let visibleSize: CGSize
			let contentOffset: CGPoint
		}
	}
	enum FetchMessage {
		struct Request {
		}
		struct Response {
			var messagesGroups: [String: [Message]]
		}
		struct ViewModel {

			var messageGroups: [MessagesGroup]
		}
	}
}

// Models
extension ChatModel {

	struct Message {
		var date: String
		var text: String

		init(text: String) {
			self.date = "01.02.24"
			self.text = text
		}

		init(apiModel: ApiMessage) {
			self.date = apiModel.date
			self.text = apiModel.title
		}
	}

	struct MessagesGroup: Mergeable, Comparable {
		let date: String
		var messages: [Message]

		static func < (lhs: Self, rhs: Self) -> Bool {
			lhs.date < rhs.date
		}

		static func == (lhs: Self, rhs: Self) -> Bool {
			lhs.date == rhs.date
		}

		func merge(_ other: Self) -> Self {
			guard other.date == date else { return self }
			var messages = self.messages
			messages.insert(contentsOf: other.messages, at: 0)

			return MessagesGroup(date: date, messages: messages)
		}
	}
}

