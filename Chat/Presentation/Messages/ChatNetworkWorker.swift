//
//  ChatNetworkWorker.swift
//  Chat
//
//  Created by Dmitry Grigoryev on 21.03.2024.
//

import Foundation

class ChatNetworkWorker {

	private let mockRequestUrl = Bundle.main.url(forResource: "mockRequestMessages", withExtension: "json")

	func fetchMessages(offset: Int, limit: Int) async -> [ApiMessage] {

		guard let mockRequestUrl else { return [] }

		try? await Task.sleep(seconds: 3)

		var result = [ApiMessage]()

		do {
			let data = try Data(contentsOf: mockRequestUrl)

			var messages = try JSONDecoder().decode([ApiMessage].self, from: data)

			messages.reverse()

			guard offset < messages.count else {
				return []
			}

			let startIndex = offset
			let endIndex = min(offset + limit, messages.count)
			let slicedMessages = messages[startIndex..<endIndex]

			result = Array(slicedMessages).reversed()
		} catch {
			print(error.localizedDescription)
		}

		return result
	}
}
