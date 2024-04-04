//
//  ChatDateSection.swift
//
//

import UIKit

// MARK: - ChatDateSection

final class ChatDateSection: UIStackView {

	private let date: String

	private var separator: UIView {
		let view = UIView()
		view.backgroundColor = .gray

		return view
	}

	private lazy var dateLabel: PaddingLabel = {
		let label = PaddingLabel()
		label.layer.cornerRadius = 13
		label.clipsToBounds = true
		label.backgroundColor = .white
		label.numberOfLines = 1

		label.textAlignment = .center
		let heightConstraint = label.heightAnchor.constraint(equalToConstant: 26)
		heightConstraint.isActive = true

		return label
	}()

	init(date: String) {
		self.date = date

		super.init(frame: .zero)

		setup()
	}

	required init(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

private extension ChatDateSection {

	func setup() {
		backgroundColor = .orange
		axis = .horizontal
		distribution = .fill
		alignment = .center
		spacing = 8
		dateLabel.text = date

		NSLayoutConstraint.activate([
			heightAnchor.constraint(greaterThanOrEqualToConstant: 42)
		])


		setupSubviews()
	}

	func setupSubviews() {
		let leftSeparator = separator
		let rightSeparator = separator

		addArrangedSubview(leftSeparator)
		addArrangedSubview(dateLabel)
		addArrangedSubview(rightSeparator)

		NSLayoutConstraint.activate([
			leftSeparator.widthAnchor.constraint(equalTo: rightSeparator.widthAnchor),
			leftSeparator.heightAnchor.constraint(equalToConstant: 1),
			rightSeparator.heightAnchor.constraint(equalToConstant: 1)
		])
	}
}

private extension ChatDateSection {

	class PaddingLabel: UILabel {

		var topInset: CGFloat = 5.0
		var bottomInset: CGFloat = 5.0
		var leftInset: CGFloat = 16.0
		var rightInset: CGFloat = 16.0

		override func drawText(in rect: CGRect) {
			let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
			super.drawText(in: rect.inset(by: insets))
		}

		override var intrinsicContentSize: CGSize {
			let size = super.intrinsicContentSize
			return CGSize(width: size.width + leftInset + rightInset,
						  height: size.height + topInset + bottomInset)
		}
	}
}
