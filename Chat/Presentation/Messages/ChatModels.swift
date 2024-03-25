//
//  ChatModels.swift
//

// MARK: - Chat
import Foundation

enum ChatModel {
	struct DataStore {
	}

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
			var values: [Int]
		}
		struct ViewModel {
			var cellTitles: [String]
		}
	}
}
