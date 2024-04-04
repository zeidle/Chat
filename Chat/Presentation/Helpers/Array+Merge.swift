//
//  Array+MessageGroup.swift
//  Chat
//

import Foundation

protocol ModelMergeable: Comparable {
	mutating func merge(_ other: Self)
}

extension Array where Element: ModelMergeable {

	mutating func merge(_ other: [Element]) {

		self = other.reduce(into: self) { partialResult, element in
			let sameElementIndex = partialResult.firstIndex { element == $0 }

			if let sameElementIndex {
				partialResult[sameElementIndex].merge(element)
			} else {
				partialResult.insert(element, at: 0)
			}
		}
	}
}
