//
//  InputTextView.swift
//

import UIKit

// MARK: - InputTextView

final class InputBarTextView: UITextView {

	typealias InputTextViewAction = (InputBarTextView) -> Void

	// MARK: - Internal properties

	enum ConstraintType {
		case top, bottom, left, right
	}

	enum Constants {
		enum Size {
			static let maxHeight: CGFloat = 250.0
			static let fontSize: CGFloat = 16.0
		}
		enum Color {
			static let colorSet = UIColor.Chat.InputBar.self
			static let textColor = colorSet.textColor
			static let placeholderColor = colorSet.placeholderColor
			static let borderColor = colorSet.borderColor?.cgColor
			static let backgroundColor = colorSet.backgroundColor
		}
	}

	override var text: String? {
		willSet {
			updatePlaceholderVisible()
			delegate?.textViewDidChange?(self)
		}
	}

	/// Текст который отображается, когда поле ввода пустое
	var placeholder: String? = "Aa" {
		didSet {
			placeholderLabel.text = placeholder
		}
	}

	var placeholderTextColor = Constants.Color.placeholderColor {
		didSet {
			placeholderLabel.textColor = placeholderTextColor
		}
	}

	/// Определяет отсутпы placeholderLabel в InputTextView
	var placeholderLabelInsets: UIEdgeInsets = UIEdgeInsets(top: 7, left: 16, bottom: 7, right: 16) {
		didSet {
			updateConstraintsForPlaceholderLabel()
		}
	}

	// https://gist.github.com/phlippieb/7524270cad67dcb8edeea0769630e491
	override var intrinsicContentSize: CGSize {
		var size = calculatedContentSize

		size.height = min(size.height, Constants.Size.maxHeight)

		return size
	}

	// MARK: - Private properties

	private var textViewHeightConstraint: NSLayoutConstraint?

	/// Набор Constraints для Placeholder
	private var placeholderLabelConstraintSet = [ConstraintType: NSLayoutConstraint]()

	private let placeholderLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 0
		label.textColor = Constants.Color.placeholderColor
		label.text = "Aa"
		label.font = .systemFont(ofSize: Constants.Size.fontSize)
		label.backgroundColor = .clear
		label.translatesAutoresizingMaskIntoConstraints = false

		return label
	}()

	private var calculatedContentSize: CGSize {
		let width: CGFloat = bounds.size.width
		let comfySize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
		return sizeThatFits(comfySize)
	}

	// MARK: - Lifecicle

	init() {
		super.init(frame: .zero, textContainer: nil)

		setup()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		if !self.bounds.size.equalTo(intrinsicContentSize) {
			self.invalidateIntrinsicContentSize()
		}
	}
}

// MARK: - InputBarTextView

private extension InputBarTextView {

	// MARK: - Internal methods

	func setup() {

		backgroundColor = Constants.Color.backgroundColor
		font = .systemFont(ofSize: Constants.Size.fontSize)
		textColor = .white
		textContainerInset = .init(top: 7, left: 10, bottom: 7, right: 10)

		layer.cornerRadius = 16
		layer.borderColor = Constants.Color.borderColor
		layer.borderWidth = 1
		keyboardAppearance = .dark

		translatesAutoresizingMaskIntoConstraints = false

		heightAnchor.constraint(greaterThanOrEqualToConstant: 32).isActive = true

		setupPlaceholderLabel()
		setupObservers()
	}

	func setupObservers() {
		NotificationCenter.default.addObserver(self,
											   selector: #selector(updatePlaceholderVisible),
											   name: UITextView.textDidChangeNotification, object: nil)
	}

	func setupPlaceholderLabel() {
		addSubview(placeholderLabel)

		placeholderLabelConstraintSet[.top] = placeholderLabel
			.topAnchor
			.constraint(equalTo: topAnchor, constant: placeholderLabelInsets.top)

		placeholderLabelConstraintSet[.left] = placeholderLabel
			.leftAnchor
			.constraint(equalTo: leftAnchor, constant: placeholderLabelInsets.left)

		placeholderLabelConstraintSet[.right] = placeholderLabel
			.rightAnchor
			.constraint(equalTo: rightAnchor, constant: placeholderLabelInsets.right)

		placeholderLabelConstraintSet[.bottom] = placeholderLabel
			.bottomAnchor
			.constraint(equalTo: bottomAnchor, constant: placeholderLabelInsets.bottom)

		placeholderLabelConstraintSet.activate()
	}

	/// Обновляет отступы для Placeholder используя placeholderLabelInsets
	func updateConstraintsForPlaceholderLabel() {

		placeholderLabelConstraintSet[.top]?.constant = placeholderLabelInsets.top
		placeholderLabelConstraintSet[.bottom]?.constant = -placeholderLabelInsets.bottom
		placeholderLabelConstraintSet[.left]?.constant = placeholderLabelInsets.left
		placeholderLabelConstraintSet[.right]?.constant = -placeholderLabelInsets.right
	}

	@objc func updatePlaceholderVisible() {
		let isPlaceholderHidden = !(text?.isEmpty ?? true)
		placeholderLabel.isHidden = isPlaceholderHidden

		// Определяем видимость элементов, во избежании конфликта
		if isPlaceholderHidden {
			placeholderLabelConstraintSet.deactivate()
		} else {
			placeholderLabelConstraintSet.activate()
		}
	}

	func scrollToCursorPosition() {
		let caret = caretRect(for: selectedTextRange!.start)
		scrollRectToVisible(caret, animated: true)
	 }


}

// MARK: - InputBarTextView

extension InputBarTextView {

	// MARK: - Internal methods

	func dismissKeyboard() {
		resignFirstResponder()
	}

}
// MARK: - Dictionary extension

private extension Dictionary where Key == InputBarTextView.ConstraintType, Value == NSLayoutConstraint {

	// MARK: - Internal methods

	func activate() {
		forEach { $0.value.isActive = true }
	}

	func deactivate() {
		forEach { $0.value.isActive = false }
	}

}
