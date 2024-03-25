//
//  ChatNetworkWorker.swift
//  Chat
//
//  Created by Dmitry Grigoryev on 21.03.2024.
//

import Foundation

class ChatNetworkWorker {

	typealias ResultCompletion = ([Int]) -> ()
	private var messages: [Int] = Array(0...100).reversed()

	func fetchMessages(offset: Int, limit: Int, _ completion: ResultCompletion?) {

		DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in

			guard let self, offset < self.messages.count else {
				completion?([])
				return
			}
			
			let startIndex = offset
			let endIndex = min(offset + limit, self.messages.count)
			let slicedMessages = messages[startIndex..<endIndex]

			completion?(Array(slicedMessages).reversed())
		}
	}
}
