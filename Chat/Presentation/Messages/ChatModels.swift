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
			var messages: [String: [String]]
		}
		struct ViewModel {

			var messageGroups: [MessageGroup]
		}
	}
}

extension ChatModel.FetchMessage.ViewModel {

	struct MessageGroup: ModelMergeable, Comparable {
		let date: String
		var messages: [String]

		static func < (lhs: Self, rhs: Self) -> Bool {
			lhs.date < rhs.date
		}

		static func == (lhs: Self, rhs: Self) -> Bool {
			lhs.date == rhs.date
		}

		mutating func merge(_ other: Self) {

			guard other.date == date else { return }

			messages.insert(contentsOf: other.messages, at: 0)
		}
	}
}

