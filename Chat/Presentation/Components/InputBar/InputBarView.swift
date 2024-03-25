//
//  InputBarView.swift
//

import UIKit

// MARK: - InputBarView

final class InputBarView: UIView {

	// MARK: - Private properties

	private var previousIntrinsicContentSize: CGSize = .zero
	private var mainStackViewRightConstraint: NSLayoutConstraint?

	private var mainStackView: UIStackView = {

		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.alignment = .trailing
		stackView.spacing = 4

		return stackView
	}()

	// MARK: - Internal properties

	lazy var inputTextView: InputBarTextView = {
		let inputTextView = InputBarTextView()
		inputTextView.delegate = self

		return inputTextView
	}()

	lazy var sendButton: InputBarSendButton = {
		let sendButton = InputBarSendButton()
		sendButton.image = .init(systemName: "arrow.up.circle.fill", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
		sendButton.tintColor = .init(named: "InputBar/sendButtonColor")
		sendButton.isHidden = true

		sendButton.onTouchUpInside { [weak self] _ in
			self?.didSelectSendButton()
		}

		return sendButton
	}()

	weak var delegate: InputBarViewDelegate?

	// MARK: - Lifecycle

	init() {
		super.init(frame: .zero)

		setup()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutIfNeeded() {
		super.layoutIfNeeded()
		inputTextView.layoutIfNeeded()
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		print("InputBarView layoutSubviews")
		defer { previousIntrinsicContentSize = frame.size }

		let prevHeight = previousIntrinsicContentSize.height
		let newHeight = frame.size.height

		guard prevHeight != 0, prevHeight != newHeight else {
			return
		}

		// Вызываем если точно уверены, что высота изменилась
		delegate?.inputBar(self, didChangeIntrinsicContentFrom: previousIntrinsicContentSize)
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}

// MARK: - InputBarView

private extension InputBarView {

	// MARK: - Internal methods

	func setup() {

		translatesAutoresizingMaskIntoConstraints = false

		setupSubviews()
	}

	func setupSubviews() {

		addSubview(mainStackView)

		mainStackView.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			mainStackView.topAnchor.constraint(equalTo: topAnchor, constant: 7),
			mainStackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
			mainStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -7)
		])
		mainStackViewRightConstraint = mainStackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16)
		mainStackViewRightConstraint?.isActive = true

		mainStackView.addArrangedSubview(inputTextView)
		mainStackView.addArrangedSubview(sendButton)
	}

	func didSelectSendButton() {
		inputTextView.text = nil
		inputTextView.dismissKeyboard()

		guard let text = inputTextView.text else { return }
		
		delegate?.inputBar(self, didPressSendButtonWith: text)
	}

}

// MARK: - InputBarViewDelegate

extension InputBarView: UITextViewDelegate {

	// MARK: - Internal methods

	func textViewDidChange(_ textView: UITextView) {

		let isTextEmpty = textView.text.isEmpty
		sendButton.isHidden = isTextEmpty

		mainStackViewRightConstraint?.constant = isTextEmpty ? -16 : -4

		self.delegate?.inputBar(self, textViewTextDidChangeTo: textView.text)
	}

}
