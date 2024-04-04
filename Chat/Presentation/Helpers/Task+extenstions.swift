//
//  Task+extenstions.swift
//  Chat
//
//  Created by Dmitry Grigoryev on 25.03.2024.
//

import Foundation

extension Task where Success == Never, Failure == Never {
	static func sleep(seconds: Double) async throws {
		let duration = UInt64(seconds * 1_000_000_000)
		try await Task.sleep(nanoseconds: duration)
	}
}
