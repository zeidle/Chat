//
//  InputBarSendButton.swift
//

import UIKit

// MARK: - InputBarSendButton

final class InputBarSendButton: UIButton {

	typealias InputBarSendButtonAction = (InputBarSendButton) -> Void

	// MARK: - Internal properties

	var image: UIImage? {
		get {
			image(for: .normal)
		}
		set {
			setImage(newValue, for: .normal)
		}
	}

	override var isEnabled: Bool {
		didSet {
			if isEnabled {
				onEnabledAction?(self)
			} else {
				onDisabledAction?(self)
			}
		}
	}

	// MARK: - Private properties

	private var onTouchUpInsideAction: InputBarSendButtonAction?
	private var onEnabledAction: InputBarSendButtonAction?
	private var onDisabledAction: InputBarSendButtonAction?
	private var onKeyboardEditingBeginsAction: InputBarSendButtonAction?
	private var onKeyboardEditingEndsAction: InputBarSendButtonAction?

	// MARK: - Lifecicle

	init() {
		super.init(frame: .zero)

		setup()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

// MARK: - InputBarSendButton

extension InputBarSendButton {

	// MARK: - Internal methods

	/// Sets the onTouchUpInsideAction
	///
	/// - Parameter action: The new onTouchUpInsideAction
	/// - Returns: Self
	@discardableResult
	func onTouchUpInside(_ action: @escaping InputBarSendButtonAction) -> Self {
		onTouchUpInsideAction = action
		return self
	}

	/// Устанавливает onEnabledAction
	///
	/// - Parameter action: onEnabledAction
	/// - Returns: Self
	@discardableResult
	func onEnabled(_ action: @escaping InputBarSendButtonAction) -> Self {
		onEnabledAction = action
		return self
	}

	/// Устанавливает onDisabledAction
	///
	/// - Parameter action: onDisabledAction
	/// - Returns: Self
	@discardableResult
	func onDisabled(_ action: @escaping InputBarSendButtonAction) -> Self {
		onDisabledAction = action
		return self
	}

	/// Устанавливает onKeyboardEditingBeginsAction
	///
	/// - Parameter action: onKeyboardEditingBeginsAction
	/// - Returns: Self
	@discardableResult
	func onKeyboardEditingBegins(_ action: @escaping InputBarSendButtonAction) -> Self {
		onKeyboardEditingBeginsAction = action
		return self
	}

	/// Устанавливает onKeyboardEditingEndsAction
	///
	/// - Parameter action: onKeyboardEditingEndsAction
	/// - Returns: Self
	@discardableResult
	func onKeyboardEditingEnds(_ action: @escaping InputBarSendButtonAction) -> Self {
		onKeyboardEditingEndsAction = action
		return self
	}
}

// MARK: - InputBarSendButton

private extension InputBarSendButton {

	// MARK: - Internal methods

	/// Первоначальная инициализация
	func setup() {

		imageView?.contentMode = .scaleAspectFit
		addTarget(self, action: #selector(touchUpInsideAction), for: .touchUpInside)

		setupConstraints()
	}

	/// Настройка Constraints
	func setupConstraints() {
		translatesAutoresizingMaskIntoConstraints = false

//		NSLayoutConstraint.activate([
//			heightAnchor.constraint(equalToConstant: 44),
//			widthAnchor.constraint(equalToConstant: 44)
//		])
	}

	/// Событие при нажатии на кнопку
	@objc func touchUpInsideAction() {
		onTouchUpInsideAction?(self)
	}
}
