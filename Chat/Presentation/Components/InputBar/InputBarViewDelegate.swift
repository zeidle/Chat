//
//  InputBarViewDelegate.swift
//

import Foundation

// MARK: - InputBarViewDelegate

protocol InputBarViewDelegate: AnyObject {
	/// Вызывается при нажатии на кнопку SendButton
	///
	/// - Parameters:
	///   - inputBar: InputBarView
	///   - text: Текущий текст InputBarView
	func inputBar(_ inputBar: InputBarView, didPressSendButtonWith text: String)

	/// Вызывается когда внутренний размер InputBarView изменился. Может быть использован для того, чтобы избежать перекрытия одного элемента, другим
	///
	/// - Parameters:
	///   - inputBar: InputBarView
	///   - size: Новый размер
	func inputBar(_ inputBar: InputBarView, didChangeIntrinsicContentFrom size: CGSize)

	/// Вызывается когда текст в InputBarView изменился
	///
	/// - Parameters:
	///   - inputBar: InputBarView
	///   - text: Текущий текст в InputBarView
	func inputBar(_ inputBar: InputBarView, textViewTextDidChangeTo text: String)
}

// MARK: - InputBarViewDelegate

extension InputBarViewDelegate {

	// MARK: - Internal methods

	func inputBar(_ inputBar: InputBarView, didPressSendButtonWith text: String) {}

	func inputBar(_ inputBar: InputBarView, didChangeIntrinsicContentFrom size: CGSize) {}

	func inputBar(_ inputBar: InputBarView, textViewTextDidChangeTo text: String) {}
}
