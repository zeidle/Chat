//
//  Array+MessageGroup.swift
//  Chat
//

import Foundation

protocol Mergeable: Comparable {
	func merge(_ other: Self) -> Self
}

extension Array where Element: Mergeable {

	func merge(_ other: [Element]) -> [Element] {

		var result = self
		other.forEach { element in
			if let index = result.firstIndex(where: { $0 == element }) {
				result[index] = result[index].merge(element)
			} else {
				result.append(element)
			}
		}
		return result
	}
}
